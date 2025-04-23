require "./spec_helper"

require "../src/client"

module ClientSpec
  struct Post
    include JSON::Serializable

    getter id : UUID
    getter author : String
    getter body : String
    getter created_at : Time
    getter updated_at : Time

    def initialize(*, @id = UUID.v4, @author, @body, @created_at = Time.utc, @updated_at = created_at)
    end

    # We don't need to worry about encoding precision of the timestamps for the
    # sake of specs.
    def_equals_and_hash id, author, body
  end

  struct Movie
    include JSON::Serializable

    getter id : Int64
    getter title : String
    getter genres : Genre

    def initialize(@id, @title, @genres)
    end

    @[Flags]
    enum Genre
      Action
      Adventure
      Drama
      Fantasy
      Romance
    end
  end

  # Testing lazy iteration for arbitrarily sized upserts
  struct Iterator(T)
    include ::Iterator(T)

    def initialize(@values : Indexable(T))
      @index = 0
      @mutex = Mutex.new
    end

    def next
      @mutex.synchronize do
        if @index >= @values.size
          stop
        else
          value = @values[@index]
          @index += 1
          value
        end
      end
    end
  end

  describe Meilisearch::Client do
    client = Meilisearch::Client.new

    if master_key = ENV["MEILISEARCH_MASTER_KEY"]? || ENV["MEILI_MASTER_KEY"]?
      it "gets API keys" do
        # TODO: Do something with this. In the meantime, the fact that it
        # executes without failure is sufficient.
        Meilisearch::Client.new(master_key).keys
      end
    else
      puts "Set the MEILISEARCH_MASTER_KEY env var to run specs that require it"
    end

    it "sets a client-level timeout" do
      c = Meilisearch::Client.new(timeout: 10.seconds)
      c.timeout.should eq 10.seconds
    end

    # This example was largely taken from the meilisearch-ruby README.md file
    it "provides a high-level API" do
      index = client.index("movies")

      documents = [
        {id: 1, title: "Carol", genres: ["Romance", "Drama"]},
        {id: 2, title: "Wonder Woman", genres: ["Action", "Adventure"]},
        {id: 3, title: "Life of Pi", genres: ["Adventure", "Drama"]},
        {id: 4, title: "Mad Max: Fury Road", genres: ["Adventure", "Science Fiction"]},
        {id: 5, title: "Moana", genres: ["Fantasy", "Action"]},
        {id: 6, title: "Philadelphia", genres: ["Drama"]},
      ]

      # If the index 'movies' does not exist, Meilisearch creates it when you first add the documents.
      task = index.add_documents!(Iterator.new(documents))

      response = index.search("carlo", as: Movie)
      response.estimated_total_hits.should eq 1
      response.query.should eq "carlo"
      response.hits.should eq [
        Movie.new(
          id: 1,
          title: "Carol",
          genres: Movie::Genre[Romance, Drama],
        ),
      ]

      index.update_filterable_attributes! %w[id genres]
      response = index.search("wonder", filter: ["id > 1 AND genres = Action"], as: Movie)
      response.hits.should eq [
        Movie.new(
          id: 2,
          title: "Wonder Woman",
          genres: Movie::Genre[Action, Adventure],
        ),
      ]
    ensure
      client.indexes.delete "movies"
    end

    describe "indexes" do
      test "creates and gets an index" do |uid, client|
        index = client.indexes.create! uid: uid, primary_key: "id"

        index.uid.should eq uid
        index.primary_key.should eq "id"
      end

      test_with_index "lists indexes" do |index, client|
        client.indexes.list.map(&.uid).should contain index.uid
      end

      test_with_index "updates an index's primary key", primary_key: "foo" do |index, client|
        updated = client.indexes.update! index, primary_key: "asdf"

        updated.primary_key.should eq "asdf"
      end

      test_with_index "updates an index's settings" do |index, client|
        client.indexes.settings.update! index,
          filterable_attributes: %w[id author]

        attrs = client.indexes.settings.get(index).filterable_attributes
        attrs.should contain "id"
        attrs.should contain "author"
      end

      test_with_index "searches for a document", primary_key: "id" do |index, client|
        included = Post.new(author: "Jamie Gaskins", body: "Include this post")
        excluded = Post.new(author: "Jamie Gaskins", body: "Exclude this post")
        client.docs.upsert! index, [included, excluded]

        results = client.indexes.search index, "included", as: Post

        results.should contain included
        results.should_not contain excluded
      end
    end

    describe "docs" do
      test_with_index "creates and gets a document by filter", primary_key: "id" do |index, client|
        client.indexes.settings.update! index, filterable_attributes: %w[id]
        post = Post.new(
          author: "Jamie Gaskins",
          body: "Hello world!",
        )
        client.docs.upsert! index, [post]

        results = client.docs.fetch index,
          filter: "id = #{post.id}",
          as: Post

        results.size.should eq 1
        results.first.should eq post
      end

      test_with_index "upserts a document patch", primary_key: "id" do |index, client|
        client.indexes.settings.update! index, filterable_attributes: %w[id]
        post = Post.new(
          author: "Jamie Gaskins",
          body: "Hello world!",
        )
        client.docs.upsert! index, [post]
        client.docs.upsert_patch! index, [{id: post.id, body: "New body"}]

        results = client.docs.fetch index,
          filter: "id = #{post.id}",
          as: Post

        results.size.should eq 1
        results.first.body.should eq "New body"
      end
    end

    describe "#multi_search" do
      it "searches multiple indexes" do
        index1 = client.indexes.create!(UUID.v7.to_s)
        index2 = client.indexes.create!(UUID.v7.to_s)
        excluded_index = client.indexes.create!(UUID.v7.to_s)
        docs = [{id: 1, name: "include"}, {id: 2, name: "exclude"}]
        [index1, index2, excluded_index].each do |index|
          # Using the same docs for all indexes
          client.docs.upsert! index, docs
        end

        begin
          response = client.multi_search(
            queries: [index1, index2].map { |index|
              client.query(q: "included", index_uid: index.uid)
            },
          )

          response.results.size.should eq 2 # index1 and index2
          response.results.map(&.index_uid).should eq [index1.uid, index2.uid]
          response.results.each do |result|
            result.hits.map(&.["id"]).should eq [1]
            result.hits.map(&.["name"]).should eq ["include"]
          end
        ensure
          client.indexes.delete index1
          client.indexes.delete index2
          client.indexes.delete excluded_index
        end
      end
    end

    describe "#federated_search" do
      it "searches multiple indexes" do
        index1 = client.indexes.create!(UUID.v7.to_s)
        index2 = client.indexes.create!(UUID.v7.to_s)
        excluded_index = client.indexes.create!(UUID.v7.to_s)
        docs = [{id: 1, name: "include"}, {id: 2, name: "exclude"}]
        [index1, index2, excluded_index].each do |index|
          # Using the same docs for all indexes
          client.docs.upsert! index, docs
        end

        begin
          response = client.federated_search(
            queries: [
              client.query(q: "included", index_uid: index1.uid),
              client.query(q: "included", index_uid: index2.uid, federation_options: Meilisearch::FederationOptions.new(weight: 1.2)),
            ],
          )

          response.size.should eq 2
          response.map(&.federation.index_uid).should eq [index2.uid, index1.uid]
          response.each do |result|
            result.hit["id"].should eq 1
            result.hit["name"].should eq "include"
          end
        ensure
          client.indexes.delete index1
          client.indexes.delete index2
          client.indexes.delete excluded_index
        end
      end
    end

    describe "stats" do
      test_with_index "returns the stats for the index", primary_key: "id" do |index, client|
        client.indexes.settings.update! index, filterable_attributes: %w[id]
        post = Post.new(
          author: "Jamie Gaskins",
          body: "Hello world!",
        )
        client.docs.upsert! index, [post]

        stats = client.indexes.stats(index)

        stats.number_of_documents.should eq 1
        stats.indexing?.should eq false
      end
    end
  end
end

private def test_with_index(name, *, primary_key : String? = nil, file = __FILE__, line = __LINE__, **options, &block : Meilisearch::Index, Meilisearch::Client ->)
  test name, **options, file: file, line: line do |index_uid, client|
    index = client.indexes.create!(index_uid, primary_key: primary_key)

    block.call index, client
  end
end

private def test(name, file = __FILE__, line = __LINE__, **options, &block : String, Meilisearch::Client ->)
  it name, **options, file: file, line: line do
    client = Meilisearch::Client.new

    uid = UUID.v4.to_s
    begin
      block.call uid, client
    ensure
      client.indexes.delete uid rescue nil
    end
  end
end

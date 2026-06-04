require "./spec_helper"

require "../src/client"

module DocumentsSpec
  struct Doc
    include JSON::Serializable
    getter id : Int64
    getter foo : String

    def initialize(@id, @foo)
    end
  end

  struct Product
    include JSON::Serializable

    getter id : Int64
    getter name : String
    getter brand : String
    getter category : Category
    getter price_cents : Int64
    getter status : Status = :available

    def initialize(@id, @name, @brand, @category, @price_cents, @status = :available)
    end

    enum Category
      Phone
      Tablet
      Speaker
    end

    enum Status
      Available
      Discontinued
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

  describe Meilisearch::Documents do
    test_with_index "upserts a lazily-evaluated enumerable of documents", primary_key: "id" do |index, client|
      products = (1..5).map do |id|
        Product.new(id: id.to_i64, brand: "Brand", category: :phone, name: "Product #{id}", price_cents: id.to_i64 * 100)
      end

      client.docs.upsert! index, Iterator.new(products)

      results = client.docs.fetch index, as: Product
      results.map(&.id).sort.should eq [1, 2, 3, 4, 5]
    end

    test_with_index "fetches documents by id", primary_key: "id" do |index, client|
      client.docs.upsert! index, [
        Product.new(id: 1, brand: "Apple", category: :phone, name: "iPhone", price_cents: 850_00),
        Product.new(id: 2, brand: "Apple", category: :tablet, name: "iPad", price_cents: 999_00),
        Product.new(id: 3, brand: "Samsung", category: :phone, name: "Galaxy", price_cents: 900_00),
      ]

      results = client.docs.fetch index, ids: %w[1 3], as: Product

      results.map(&.id).sort.should eq [1, 3]
    end

    test_with_index "paginates documents with limit and offset", primary_key: "id" do |index, client|
      client.indexes.settings.update! index, sortable_attributes: %w[price_cents]
      client.docs.upsert! index, (1..5).map { |id|
        Product.new(id: id.to_i64, brand: "Brand", category: :phone, name: "Product #{id}", price_cents: id.to_i64 * 100)
      }

      page = client.docs.fetch index,
        offset: 1_i64,
        limit: 2,
        sort: %w[price_cents:asc],
        as: Product

      page.results.map(&.id).should eq [2, 3]
      page.limit.should eq 2
      page.offset.should eq 1
      page.total.should eq 5
    end

    test_with_index "fetches only the requested fields", primary_key: "id" do |index, client|
      client.docs.upsert! index, [
        Product.new(id: 1, brand: "Apple", category: :phone, name: "iPhone", price_cents: 850_00),
      ]

      results = client.docs.fetch index, fields: %w[id name]

      results.first.as_h.keys.sort.should eq %w[id name]
    end

    test_with_index "sorts documents", primary_key: "id" do |index, client|
      client.indexes.settings.update! index, sortable_attributes: %w[price_cents]
      client.docs.upsert! index, [
        Product.new(id: 1, brand: "Apple", category: :phone, name: "iPhone", price_cents: 850_00),
        Product.new(id: 2, brand: "Apple", category: :tablet, name: "iPad", price_cents: 999_00),
        Product.new(id: 3, brand: "Samsung", category: :speaker, name: "Alexa", price_cents: 200_00),
      ]

      results = client.docs.fetch index, sort: %w[price_cents:desc], as: Product

      results.map(&.id).should eq [2, 1, 3]
    end

    test_with_index "deletes a document by id", primary_key: "id" do |index, client|
      client.docs.upsert! index, [
        Product.new(id: 1, brand: "Apple", category: :phone, name: "iPhone", price_cents: 850_00),
        Product.new(id: 2, brand: "Apple", category: :tablet, name: "iPad", price_cents: 999_00),
      ]

      client.wait_for_task client.docs.delete(index, 1)

      results = client.docs.fetch index, as: Product
      results.map(&.id).should eq [2]
    end

    test_with_index "deletes all documents" do |index, client|
      client.documents.upsert index, [{id: 1, foo: "bar"}]
      client.documents.delete_all! index

      client.documents.fetch(index).should be_empty
    end

    test_with_index "deletes all documents matching a filter" do |index, client|
      client.indexes.settings.update index, filterable_attributes: %w[foo]
      first = Doc.new(id: 1, foo: "bar")
      second = Doc.new(id: 2, foo: "baz")
      client.documents.upsert index, [first, second]

      client.documents.delete! index, filter: "foo = 'baz'"

      docs = client.documents.fetch(index, as: Doc)
      docs.should contain first
      docs.should_not contain second # We deleted it with the filter
    end
  end
end

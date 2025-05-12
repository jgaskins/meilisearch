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

  describe Meilisearch::Documents do
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

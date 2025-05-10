require "./spec_helper"

require "../src/client"

describe Meilisearch::Batches do
  client = Meilisearch::Client.new

  describe "#list" do
    it "lists the batches" do
      client.batches.list
    end

    test_with_index "lists batches for specific index uids" do |index|
      result = client.batches.list(index_uids: [index.uid])

      # It should only have the specified index's uid
      result.first.stats.index_uids.has_key?(index.uid).should eq true
      result
        .all? { |batch| batch.stats.index_uids.size == 1 }
        .should eq true
    end
  end
end

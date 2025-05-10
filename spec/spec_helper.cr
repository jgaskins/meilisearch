require "spec"
require "../src/meilisearch"

def test_with_index(name, *, primary_key : String? = nil, file = __FILE__, line = __LINE__, **options, &block : Meilisearch::Index, Meilisearch::Client ->)
  test name, **options, file: file, line: line do |index_uid, client|
    index = client.indexes.create!(index_uid, primary_key: primary_key)

    block.call index, client
  end
end

def test(name, file = __FILE__, line = __LINE__, **options, &block : String, Meilisearch::Client ->)
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

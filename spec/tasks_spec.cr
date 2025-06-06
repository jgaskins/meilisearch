require "./spec_helper"

require "../src/client"

describe Meilisearch::Tasks do
  client = Meilisearch::Client.new
  test "gets tasks" do |uid|
    task = client.indexes.create uid
    client.tasks
      .get(index_uids: [uid])
      .map(&.uid)
      .should contain task.task_uid
  ensure
    client.indexes.delete uid
  end
end

require "./api"
require "./client"

module Meilisearch
  struct IndexClient < API
    def initialize(@uid : String, @client : Client)
      super client
    end

    def add_documents!(docs : Enumerable)
      task = client.wait_for_task(client.docs.upsert(@uid, docs))
      successful task do
      end
    end

    def add_documents(docs : Enumerable)
      @client.docs.upsert @uid, docs
    end

    def search(q : String? = nil, **options)
      @client.indexes.search @uid, **options, query: q
    end

    def update_filterable_attributes!(attributes : Array(String), timeout : Time::Span = client.timeout)
      successful(client.wait_for_task(update_filterable_attributes(attributes), timeout: timeout)) do
      end
    end

    def update_filterable_attributes(attributes : Array(String))
      @client.indexes.settings.update @uid, filterable_attributes: attributes
    end
  end
end

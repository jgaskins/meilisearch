require "./api"
require "./resource"

module Meilisearch
  struct Documents < API
    # Upsert `documents` into the index specified by `index`, overwriting the
    # entire documents if they already exist, and wait until all of the upserted
    # documents are successfully indexed before returning, up to `timeout`.
    #
    # ```
    # meilisearch.docs.upsert! index, [{id: 1, email: "jamie@example.com"}]
    # ```
    def upsert!(index : Index, documents : Enumerable, timeout : Time::Span = client.timeout)
      upsert! index.uid, documents, timeout: timeout
    end

    # Upsert `documents` into the index with the given `index_uid`, overwriting the
    # entire documents if they already exist, and wait until all of the upserted
    # documents are successfully indexed before returning, up to `timeout`.
    #
    # ```
    # meilisearch.docs.upsert! "users", [{id: 1, email: "jamie@example.com"}]
    # ```
    def upsert!(index_uid : String, documents : Enumerable, timeout : Time::Span = client.timeout)
      task = client.wait_for_task(upsert(index_uid, documents: documents), timeout: timeout)
      successful(task) { fetch index_uid }
    end

    # Upsert `documents` into the index specified by `index`, overwriting the
    # entire documents if they already exist, and immediately return, not waiting
    # for indexing.
    #
    # ```
    # meilisearch.docs.upsert index, [{id: 1, email: "jamie@example.com"}]
    # ```
    def upsert(index : Index, documents : Enumerable)
      upsert index.uid, documents
    end

    # Upsert `documents` into the index specified by `index`, overwriting the
    # entire documents if they already exist, and immediately return, not waiting
    # for indexing.
    #
    # NOTE: If you have a large number of documents to index, consider upserting
    # them using a lazy iterator to consume less memory both in your Crystal
    # application and in the Meilisearch server.
    #
    # ```
    # meilisearch.docs.upsert "users", [{id: 1, email: "jamie@example.com"}]
    # ```
    def upsert(index_uid : String, documents : Array)
      upsert_impl index_uid, documents.to_json
    end

    # Upsert `documents` into the index specified by `index`, overwriting the
    # entire documents if they already exist, and immediately return, not waiting
    # for indexing.
    #
    # This overload is useful for upserting a large number of documents without
    # having to hold all of their JSON representations in memory either in your
    # Crystal application or on the Meilisearch server. You can use iterators or
    # other `Enumerable` objects that can consume a collection one item at a
    # time, such as an [`Interro::QueryBuilder`](https://github.com/jgaskins/interro?tab=readme-ov-file#querybuildert).
    #
    # ```
    # meilisearch.docs.upsert "users", [{id: 1, email: "jamie@example.com"}]
    # ```
    def upsert(index_uid : String, documents : Enumerable)
      reader, writer = IO.pipe
      spawn do
        documents.each do |doc|
          JSON.build writer do |json|
            doc.to_json json
          end
          writer.puts
        end
      ensure
        writer.close
      end

      upsert_impl index_uid, reader, headers: HTTP::Headers{
        "Content-Type" => "application/x-ndjson",
      }
    end

    private def upsert_impl(index_uid : String, body, headers : HTTP::Headers? = nil)
      response(
        http.post("/indexes/#{index_uid}/documents", headers: headers, body: body),
        as: TaskResult,
      )
    end

    # Upsert `documents` into the index specified by `index`, patching partial
    # documents if they already exists, and wait until all of the upserted
    # documents are successfully indexed before returning, up to `timeout`.
    #
    # ```
    # meilisearch.docs.upsert_patch! index, [{id: 1, email: "jamie@example.com"}]
    # ```
    def upsert_patch!(index : Index, documents : Enumerable, timeout : Time::Span = client.timeout)
      upsert_patch! index.uid, documents, timeout: timeout
    end

    # Upsert `documents` into the index specified by `index`, patching partial
    # documents if they already exists, and wait until all of the upserted
    # documents are successfully indexed before returning, up to `timeout`.
    #
    # ```
    # meilisearch.docs.upsert_patch! "users", [{id: 1, email: "jamie@example.com"}]
    # ```
    def upsert_patch!(index_uid : String, documents : Enumerable, timeout : Time::Span = client.timeout)
      task = client.wait_for_task(upsert_patch(index_uid, documents: documents), timeout: timeout)
      successful(task) { fetch index_uid }
    end

    # Upsert `documents` into the index specified by `index`, patching partial
    # documents if they already exists, and return immediately, not waiting
    # for indexing.
    #
    # ```
    # meilisearch.docs.upsert_patch index, [{id: 1, email: "jamie@example.com"}]
    # ```
    def upsert_patch(index : Index, documents : Enumerable)
      upsert_patch index.uid, documents
    end

    # Upsert `documents` into the index specified by `index`, patching partial
    # documents if they already exists, and return immediately, not waiting
    # for indexing.
    #
    # ```
    # meilisearch.docs.upsert_patch "users", [{id: 1, email: "jamie@example.com"}]
    # ```
    def upsert_patch(index_uid : String, documents : Array)
      upsert_patch_impl index_uid, documents.to_json
    end

    # Upsert `documents` into the index specified by `index`, patching partial
    # documents if they already exists, and return immediately, not waiting
    # for indexing.
    #
    # This overload is useful for upserting a large number of documents without
    # having to hold all of their JSON representations in memory either in your
    # Crystal application or on the Meilisearch server. You can use iterators or
    # other `Enumerable` objects that can consume a collection one item at a
    # time, such as an [`Interro::QueryBuilder`](https://github.com/jgaskins/interro?tab=readme-ov-file#querybuildert).
    #
    # ```
    # meilisearch.docs.upsert_patch "users", UserQuery.new
    # ```
    def upsert_patch(index_uid : String, documents : Enumerable)
      reader, writer = IO.pipe
      spawn do
        documents.each do |doc|
          doc.to_json writer
          writer.puts
        end
      ensure
        writer.close
      end

      upsert_patch_impl index_uid, reader
    end

    private def upsert_patch_impl(index_uid : String, body)
      response(
        http.put("/indexes/#{index_uid}/documents", body: body),
        as: TaskResult,
      )
    end

    # Fetch the documents with the given filter and convert them to the type `T`.
    #
    # NOTE: This is not for full-text queries. This is strictly about filtering.
    #
    # ```
    # meilisearch.docs.fetch index, filter: "status = 'active'", as: User
    # ```
    def fetch(index : Index, *, filter : String | Array(String) | Nil = nil, as type : T.class = JSON::Any) forall T
      fetch index.uid, filter: filter, as: T
    end

    # Fetch the documents with the given filter and convert them to the type `T`.
    #
    # NOTE: This is not for full-text queries. This is strictly about filtering.
    #
    # ```
    # meilisearch.docs.fetch "users", filter: "status = 'active'", as: User
    # ```
    def fetch(index_uid : String, *, filter : String | Array(String) | Nil = nil, as type : T.class = JSON::Any) forall T
      request = FetchRequest.new(
        filter: filter,
      )
      response(
        http.post("/indexes/#{index_uid}/documents/fetch", body: request.to_json),
        as: List(T)
      )
    end

    # Delete the document whose primary key is `document_id` from the given
    # `index`.
    #
    # ```
    # meilisearch.docs.delete index, 1
    # ```
    def delete(index : Index, document_id : String | Int32)
      delete index.uid, document_id
    end

    # Delete the document whose primary key is `document_id` from the index
    # with the given `index_uid`.
    #
    # ```
    # meilisearch.docs.delete "users", 1
    # ```
    def delete(index_uid : String, document_id : String | Int32)
      response(
        http.delete("/indexes/#{index_uid}/documents/#{document_id}"),
        as: TaskResult,
      )
    end

    private struct FetchRequest < Resource
      field filter : String | Array(String) | Nil
      field fields : Array(String)?
      field offset : Int64?
      field limit : Int32?

      def initialize(
        *,
        @offset = nil,
        @limit = nil,
        @fields = nil,
        @filter = nil,
      )
      end
    end
  end
end

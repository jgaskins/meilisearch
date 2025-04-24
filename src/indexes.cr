require "./api"
require "./list"
require "./index"
require "./task"
require "./resource"
require "./query"

module Meilisearch
  struct Indexes < API
    def list(offset : Int? = nil, limit : Int? = nil)
      params = URI::Params.new
      params["offset"] = offset.to_s if offset
      params["limit"] = limit.to_s if limit

      response http.get("/indexes?#{params}"), as: List(Index)
    end

    def get?(uid : String) : Index?
      response = http.get("/indexes/#{uid}")
      case response.status
      when .success?
        body = response.body_io? || response.body
        Index.from_json body
      when .not_found?
        nil
      else
        body = response.body_io?.try(&.gets_to_end) || response.body
        raise Error.new("Unexpected response from Meilisearch: #{response.status} (#{response.status.code}) - #{body}")
      end
    end

    def get(uid : String) : Index
      response(
        http.get("/indexes/#{uid}"),
        as: Index
      )
    end

    def search(index : Index, query : String, as type : T.class = JSON::Any) forall T
      search index.uid, query: query, as: T
    end

    def search(
      uid : String,
      query : String? = nil,
      offset : Int? = nil,
      limit : Int? = nil,
      hits_per_page : Int? = nil,
      page : Int? = nil,
      filter : String | Array(String) | Nil = nil,
      facets : Array(String)? = nil,
      attributes_to_retrieve : Array(String)? = nil,
      attributes_to_crop : Array(String)? = nil,
      crop_length : Int? = nil,
      crop_marker : String? = nil,
      attributes_to_highlight : Array(String)? = nil,
      highlight_pre_tag : String? = nil,
      highlight_post_tag : String? = nil,
      show_matches_position : Bool? = nil,
      sort : Array(String)? = nil,
      matching_strategy : String? = nil,
      show_ranking_score : Bool? = nil,
      show_ranking_score_details : Bool? = nil,
      ranking_score_threshold : Float? = nil,
      attributes_to_search_on : Array(String)? = nil,
      hybrid : JSON::Any? = nil,
      vector : Array(Float64)? = nil,
      retrieve_vectors : Bool? = nil,
      locales : Array(String)? = nil,
      *,
      as type : T.class = JSON::Any,
    ) forall T
      request = Query.new(
        **pass(
          offset,
          limit,
          hits_per_page,
          page,
          filter,
          facets,
          attributes_to_retrieve,
          attributes_to_crop,
          crop_length,
          crop_marker,
          attributes_to_highlight,
          highlight_pre_tag,
          highlight_post_tag,
          show_matches_position,
          sort,
          matching_strategy,
          show_ranking_score,
          show_ranking_score_details,
          ranking_score_threshold,
          attributes_to_search_on,
          hybrid,
          vector,
          retrieve_vectors,
          locales,
        ),
        q: query,
      )
      response(
        http.post("/indexes/#{uid}/search", body: request.to_json),
        as: SearchResponse(T),
      )
    end

    def create!(uid : String, *, primary_key : String? = nil, timeout : Time::Span = client.timeout)
      task = client.wait_for_task(uid: create(uid: uid, primary_key: "id").task_uid, timeout: timeout)
      successful(task) { get(uid) }
      # if task.status.succeeded?
      #   client.indexes.get(uid)
      # else
      #   unsuccessful task
      # end
    end

    def create(uid : String, *, primary_key : String? = nil)
      response(
        http.post(
          "/indexes",
          body: {
            uid:        uid,
            primaryKey: primary_key,
          }.to_json,
        ),
        as: TaskResult,
      )
    end

    def update!(index : Index, *, primary_key : String? = nil)
      update! index.uid, primary_key: primary_key
    end

    def update!(index_uid uid : String, primary_key : String? = nil, timeout : Time::Span = client.timeout)
      task = client.wait_for_task(uid: update(uid, primary_key: primary_key).task_uid, timeout: timeout)
      if task.status.succeeded?
        client.indexes.get(uid)
      else
        unsuccessful task
      end
    end

    def update(index_uid uid : String, *, primary_key : String? = nil)
      response(
        http.patch("/indexes/#{uid}", body: {primaryKey: primary_key}.to_json),
        as: TaskResult,
      )
    end

    def delete(index : Index)
      delete index.uid
    end

    def delete(uid : String)
      response http.delete("/indexes/#{uid}"), as: TaskResult
    end

    def settings
      SettingsAPI.new client
    end

    def stats(index : Index)
      stats index.uid
    end

    def stats(index_uid : String)
      response(
        http.get("/indexes/#{index_uid}/stats"),
        as: Stats,
      )
    end

    struct Stats < Resource
      field number_of_documents : Int64
      field? indexing : Bool, key: "isIndexing"
      field field_distribution : Hash(String, Int64)
    end

    struct Settings < Resource
      field displayed_attributes : Array(String)
      field searchable_attributes : Array(String)
      field filterable_attributes : Array(String)
      field sortable_attributes : Array(String)
      field ranking_rules : Array(String)
    end

    struct SettingsAPI < API
      def get(index : Index)
        get index.uid
      end

      def get(index_uid uid : String)
        response(
          http.get("/indexes/#{uid}/settings"),
          as: Settings,
        )
      end

      def update!(
        index : Index,
        *,
        displayed_attributes : Array(String)? = nil,
        searchable_attributes : Array(String)? = nil,
        filterable_attributes : Array(String)? = nil,
        sortable_attributes : Array(String)? = nil,
        ranking_rules : Array(String)? = nil,
      )
        update! index.uid,
          filterable_attributes: filterable_attributes,
          displayed_attributes: displayed_attributes,
          searchable_attributes: searchable_attributes,
          sortable_attributes: sortable_attributes,
          ranking_rules: ranking_rules
      end

      def update!(
        uid : String,
        *,
        displayed_attributes : Array(String)? = nil,
        searchable_attributes : Array(String)? = nil,
        filterable_attributes : Array(String)? = nil,
        sortable_attributes : Array(String)? = nil,
        ranking_rules : Array(String)? = nil,
      )
        task = update uid,
          filterable_attributes: filterable_attributes,
          displayed_attributes: displayed_attributes,
          searchable_attributes: searchable_attributes,
          sortable_attributes: sortable_attributes,
          ranking_rules: ranking_rules
        task = client.wait_for_task(task, timeout: 2.seconds)

        successful(task) { get uid }
      end

      def update(
        index : Index,
        *,
        displayed_attributes : Array(String)? = nil,
        searchable_attributes : Array(String)? = nil,
        filterable_attributes : Array(String)? = nil,
        sortable_attributes : Array(String)? = nil,
        ranking_rules : Array(String)? = nil,
      )
        update index.uid,
          filterable_attributes: filterable_attributes,
          displayed_attributes: displayed_attributes,
          searchable_attributes: searchable_attributes,
          sortable_attributes: sortable_attributes,
          ranking_rules: ranking_rules
      end

      def update(
        uid : String,
        *,
        displayed_attributes : Array(String)? = nil,
        searchable_attributes : Array(String)? = nil,
        filterable_attributes : Array(String)? = nil,
        sortable_attributes : Array(String)? = nil,
        ranking_rules : Array(String)? = nil,
      )
        request = UpdateRequest.new(
          filterable_attributes: filterable_attributes,
          displayed_attributes: displayed_attributes,
          searchable_attributes: searchable_attributes,
          sortable_attributes: sortable_attributes,
          ranking_rules: ranking_rules
        )

        response(
          http.patch("/indexes/#{uid}/settings", body: request.to_json),
          as: TaskResult,
        )
      end

      struct UpdateRequest < Resource
        field displayed_attributes : Array(String)?
        field searchable_attributes : Array(String)?
        field filterable_attributes : Array(String)?
        field sortable_attributes : Array(String)?
        field ranking_rules : Array(String)?

        def initialize(
          *,
          displayed_attributes : Array(String)? = nil,
          searchable_attributes : Array(String)? = nil,
          filterable_attributes : Array(String)? = nil,
          sortable_attributes : Array(String)? = nil,
          ranking_rules : Array(String)? = nil,
        )
          @displayed_attributes = displayed_attributes
          @searchable_attributes = searchable_attributes
          @filterable_attributes = filterable_attributes
          @sortable_attributes = sortable_attributes
          @ranking_rules = ranking_rules
        end
      end
    end
  end
end

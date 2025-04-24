require "./api"
require "./indexes"
require "./resource"
require "./search_response"

module Meilisearch
  struct MultiSearch < API
    def call(queries : Enumerable(Query), federation = nil, *, as type : T.class = JSON::Any) forall T
      response http.post("/multi-search", body: {queries: queries, federation: federation}.to_json),
        as: T
    end

    Resource.define FederationOptions,
      offset : Int64? = nil,
      limit : Int32? = nil,
      facets_by_index : Hash(String, Array(String))? = nil,
      merge_facets : Hash(String, JSON::Any)? = nil

    struct Response(T) < Resource
      field results : Array(SearchResponse(T))
    end

    struct FederatedResult(T) < Resource
      field hit : T
      field federation : Federation::Metadata

      def initialize(json : JSON::PullParser)
        # TODO: Let's see if we can make this more efficient.
        parsed = JSON::Any.new(json)
        federation = parsed.as_h.delete("_federation")
        @hit = T.from_json(parsed.to_json)
        @federation = Federation::Metadata.from_json(federation.to_json)
      end
    end
  end

  module Federation
    struct Metadata < Resource
      field index_uid : String
      field queries_position : Int64
      field weighted_ranking_score : Float64
    end
  end
end

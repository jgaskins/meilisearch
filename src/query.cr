require "./resource"

module Meilisearch
  struct Query < Resource
    field q : String?
    field index_uid : String?
    field offset : Int64?
    field limit : Int64?
    field hits_per_page : Int64?
    field page : Int64?
    field filter : String | Array(String) | Nil
    field facets : Array(String)?
    field attributes_to_retrieve : Array(String)?
    field attributes_to_crop : Array(String)?
    field crop_length : Int64?
    field crop_marker : String?
    field attributes_to_highlight : Array(String)?
    field highlight_pre_tag : String?
    field highlight_post_tag : String?
    field show_matches_position : Bool?
    field sort : Array(String)?
    field matching_strategy : String?
    field show_ranking_score : Bool?
    field show_ranking_score_details : Bool?
    field ranking_score_threshold : Float64?
    field attributes_to_search_on : Array(String)?
    field hybrid : JSON::Any?
    field vector : Array(Float64)?
    field retrieve_vectors : Bool?
    field locales : Array(String)?
    field federation_options : FederationOptions?

    def initialize(
      *,
      @q = nil,
      @index_uid = nil,
      @offset = nil,
      @limit = nil,
      @hits_per_page = nil,
      @page = nil,
      @filter = nil,
      @facets = nil,
      @attributes_to_retrieve = nil,
      @attributes_to_crop = nil,
      @crop_length = nil,
      @crop_marker = nil,
      @attributes_to_highlight = nil,
      @highlight_pre_tag = nil,
      @highlight_post_tag = nil,
      @show_matches_position = nil,
      @sort = nil,
      @matching_strategy = nil,
      @show_ranking_score = nil,
      @show_ranking_score_details = nil,
      @ranking_score_threshold = nil,
      @attributes_to_search_on = nil,
      @hybrid = nil,
      @vector = nil,
      @retrieve_vectors = nil,
      @locales = nil,
      @federation_options = nil,
    )
    end

    # https://www.meilisearch.com/docs/reference/api/search#matching-strategy
    enum MatchingStrategy
      Last
      All
      Frequency
    end
  end

  struct FederationOptions < Resource
    field weight : Float64?

    def initialize(
      *,
      @weight = nil,
    )
    end
  end
end

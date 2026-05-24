require "./resource"

module Meilisearch
  struct RankingRule < Resource
    field order : Int64
    field score : Float64
    field matching_words : Int64?
    field max_matching_words : Int64?
    field typo_count : Int64?
    field max_typo_count : Int64?
    field match_type : String?
  end
end

require "./resource"

module Meilisearch
  struct MatchPosition < Resource
    getter start : Int64
    getter length : Int64
  end
end

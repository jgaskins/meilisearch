require "./resource"

module Meilisearch
  Resource.define HybridSearch,
    semantic_ratio : Float64? = nil,
    embedder : String
end

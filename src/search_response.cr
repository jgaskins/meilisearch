require "./resource"
require "./span_milliseconds_converter"

module Meilisearch
  struct SearchResponse(T) < Resource
    include Enumerable(T)

    field hits : Array(T)
    field query : String?
    field processing_time : Time::Span, key: "processingTimeMs", converter: Meilisearch::SpanMillisecondsConverter
    field estimated_total_hits : Int64
    field index_uid : String?
    field limit : Int32
    field offset : Int64
    field facets_by_index : Hash(String, Facet)?

    delegate each, to: hits

    Resource.define Facet,
      distribution : Hash(String, Distribution),
      stats : Hash(String, Stats) do
      include JSON::Serializable::Unmapped
      alias Distribution = Hash(String, Int64)

      Resource.define Stats,
        min : Float64,
        max : Float64 do
        include JSON::Serializable::Unmapped
      end
    end
  end
end

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

    delegate each, to: hits
  end
end

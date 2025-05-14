require "./resource"

module Meilisearch
  struct List(T) < Resource
    include Enumerable(T)

    field results : Array(T)
    field offset : Int64 = 0
    field limit : Int64
    field total : Int64

    delegate each, to: results
  end
end

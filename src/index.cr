require "./resource"

module Meilisearch
  struct Index < Resource
    field uid : String
    field primary_key : String?
    field created_at : Time
    field updated_at : Time

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
      field typo_tolerance : TypoTolerance
      field embedders : Embedders
    end

    struct TypoTolerance < Resource
      field? enabled : Bool? = nil
      field min_word_size_for_typos : MinWordSizeForTypos? = nil
      field disable_on_words : Array(String) { [] of String }
      field disable_on_attributes : Array(String) { [] of String }

      def initialize(
        *,
        @enabled = nil,
        @min_word_size_for_typos = nil,
        @disable_on_words = nil,
        @disable_on_attributes = nil,
      )
      end

      Resource.define MinWordSizeForTypos,
        one_typo : Int64? = nil,
        two_typos : Int64? = nil
    end

    alias Embedders = Hash(String, Index::Embedder)

    Resource.define Embedder,
      source : Source,
      url : URI | String | Nil = nil,
      api_key : String? = nil,
      model : String? = nil,
      document_template : String? = nil,
      document_template_max_bytes : Int64? = nil,
      dimensions : Int64? = nil,
      revision : String? = nil,
      distribution : JSON::Any? = nil,
      request : JSON::Any? = nil,
      response : JSON::Any? = nil,
      binary_quantized : Bool? = nil,
      indexing_embedder : JSON::Any? = nil,
      search_embedder : JSON::Any? = nil,
      pooling : String? = nil do
      enum Source
        OpenAI
        HuggingFace
        Ollama
        REST
        UserProvided
        Composite

        def to_json(json : JSON::Builder)
          json.string do |io|
            to_s.camelcase io, lower: true
          end
        end
      end
    end
  end
end

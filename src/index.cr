require "./resource"

module Meilisearch
  struct Index < Resource
    field uid : String
    field primary_key : String?
    field created_at : Time
    field updated_at : Time
  end
end

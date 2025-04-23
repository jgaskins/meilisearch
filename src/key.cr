require "json"
require "uuid/json"

module Meilisearch
  struct Key
    include JSON::Serializable

    getter name : String
    getter description : String?
    getter key : String
    getter uid : UUID
    getter actions : Array(String)
    getter indexes : Array(String)
    @[JSON::Field(key: "expiresAt")]
    getter expires_at : Time?
    @[JSON::Field(key: "createdAt")]
    getter created_at : Time
    @[JSON::Field(key: "updatedAt")]
    getter updated_at : Time
  end
end

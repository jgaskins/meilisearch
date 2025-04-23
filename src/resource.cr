require "json"
require "uuid/json"
require "uri/json"
require "duration"

module Meilisearch
  abstract struct Resource
    include JSON::Serializable
    # Uncomment this when debugging deserialization
    # include JSON::Serializable::Unmapped

    {% for prefix in ["", "?", "!"] %}
      macro field{{prefix.id}}(var, key = nil, **options, &block)
        @[JSON::Field(key: \{{key || var.var.camelcase(lower: true)}}, \{{options.double_splat}})]
        getter{{prefix.id}} \{{var}} \{{block}}
      end
    {% end %}
  end

  module DurationConverter
    extend self

    def from_json(json : JSON::PullParser)
      Duration.parse_iso8601(json.read_string).to_span
    end
  end
end

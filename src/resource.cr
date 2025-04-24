require "json"
require "uuid/json"
require "uri/json"
require "duration"

module Meilisearch
  abstract struct Resource
    include JSON::Serializable

    # Uncomment this when debugging deserialization
    # include JSON::Serializable::Unmapped

    macro define(name, *properties)
      struct {{name}} < {{@type}}
        {% for property in properties %}
          field {{property}}
        {% end %}

        def initialize(
          *,
          {% for property in properties %}
            @{{property.var}}{% unless property.value.is_a? Nop %} = {{property.value}}{% end %},
          {% end %}
        )
        end

        {{yield}}
      end
    end

    {% for prefix in ["?", "!"] %}
      macro field{{prefix.id}}(var, key = nil, **options, &block)
        @[JSON::Field(key: \{{key || var.var.camelcase(lower: true)}}, \{{options.double_splat}})]
        getter{{prefix.id}} \{{var}} \{{block}}
      end
    {% end %}

    macro field(var, key = nil, **options, &block)
      @[JSON::Field(key: {{key || var.var.camelcase(lower: true)}}, {{options.double_splat}})]
      getter {{var}} {{block}}

      {% if var.type.is_a?(Union) && var.type.types.any? { |type| type.id.stringify == "::Nil" } %}
        def {{var.var}}!
          @{{var.var}} || raise MissingValue.new("{{var.var}} is missing, expected not to be nil")
        end
      {% end %}
    end

    class MissingValue < Error
    end
  end

  module DurationConverter
    extend self

    def from_json(json : JSON::PullParser)
      Duration.parse_iso8601(json.read_string).to_span
    end
  end
end

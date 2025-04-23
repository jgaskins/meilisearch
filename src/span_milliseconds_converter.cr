module Meilisearch
  module SpanMillisecondsConverter
    extend self

    def from_json(json : JSON::PullParser)
      json.read_int.milliseconds
    end
  end
end

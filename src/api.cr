require "http"

require "./client"
require "./error"

module Meilisearch
  abstract struct API
    getter client : Client
    getter http : HTTP::Client

    def initialize(@client, @http = client.http)
    end

    private def response(response : HTTP::Client::Response, as return_type : T.class) forall T
      if response.success?
        body = response.body_io? || response.body
        T.from_json body
      else
        body = response.body_io?.try(&.gets_to_end) || response.body
        raise Error.new("Unexpected response from Meilisearch: #{response.status} (#{response.status.code}) - #{body}")
      end
    end

    private def successful(task : Task, &)
      if task.status.succeeded?
        yield
      else
        unsuccessful task
      end
    end

    private def unsuccessful(task : Task)
      raise TaskUnsuccessful.new("Task did not succeed: #{task}")
    end

    class Error < Meilisearch::Error
    end

    class TaskUnsuccessful < Error
    end
  end
end

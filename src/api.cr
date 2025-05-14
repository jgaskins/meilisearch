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
        T.from_json response.body
      else
        raise Error.from_json(response.body)
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

    # :nodoc:
    macro pass(*args)
      {
        {% for arg in args %}
          {{arg}}: {{arg}},
        {% end %}
      }
    end

    class Exception < Meilisearch::Exception
    end

    class TaskUnsuccessful < Exception
    end
  end
end

require "http_client"
require "json"
require "uuid"

require "./error"
require "./key"

module Meilisearch
  class Client
    protected getter http : HTTP::Client
    getter timeout : Time::Span

    def initialize(
      api_key = ENV["MEILISEARCH_API_KEY"],
      uri : URI = URI.parse("http://localhost:7700/?max_idle_pool_size=25"),
      @timeout = 5.seconds,
    )
      authorization = "Bearer #{api_key}"
      user_agent = "https://github.com/jgaskins/meilisearch; #{VERSION}"

      @http = HTTPClient.new(uri)
      @http.before_request do |request|
        request.headers["Authorization"] = authorization
        request.headers["Accept"] ||= "application/json"
        unless request.method.in?({"GET", "HEAD"})
          request.headers["Content-Type"] ||= "application/json"
        end
        request.headers["User-Agent"] = user_agent
      end
    end

    def keys
      response = @http.get "/keys"
      if response.success?
        List(Key).from_json response.body
      else
        raise API::Error.new("Unexpected response from Meilisearch: #{response.status} (#{response.status.code}) - #{response.body}")
      end
    end

    def multi_search(
      queries : Array(Query),
      as type : T.class = JSON::Any,
    ) forall T
      MultiSearch.new(self).call queries, as: MultiSearch::Response(T)
    end

    def federated_search(
      queries : Enumerable(Query),
      federation = NamedTuple.new,
      as type : T.class = JSON::Any,
    ) forall T
      MultiSearch.new(self).call queries, federation,
        as: SearchResponse(MultiSearch::FederatedResult(T))
    end

    def query(**options) : Query
      Query.new(**options)
    end

    def index(uid : String) : IndexClient
      IndexClient.new(uid, self)
    end

    def indexes
      Indexes.new self
    end

    # Alias for `documents`
    def docs
      documents
    end

    # The `Documents` API in the context of the current client
    def documents
      Documents.new self
    end

    def wait_for_task(task : Task, *, timeout : Time::Span = self.timeout, poll_interval : Time::Span = 100.milliseconds)
      wait_for_task task.uid, timeout: timeout, poll_interval: poll_interval
    end

    def wait_for_task(task : Task, *, timeout : Time::Span = self.timeout, poll_interval : Time::Span = 100.milliseconds, &)
      wait_for_task task.uid, timeout: timeout, poll_interval: poll_interval do
        yield
      end
    end

    def wait_for_task(task : TaskResult, *, timeout : Time::Span = self.timeout, poll_interval : Time::Span = 100.milliseconds)
      wait_for_task task.task_uid, timeout: timeout, poll_interval: poll_interval
    end

    def wait_for_task(task : TaskResult, *, timeout : Time::Span = self.timeout, poll_interval : Time::Span = 100.milliseconds, &)
      wait_for_task task.task_uid, timeout: timeout, poll_interval: poll_interval do
        yield
      end
    end

    def wait_for_task(uid : Int64, *, timeout : Time::Span = self.timeout, poll_interval : Time::Span = 100.milliseconds)
      wait_for_task uid, timeout: timeout, poll_interval: poll_interval do
        raise TaskTimeout.new("Task timed out after #{timeout}")
      end
    end

    def wait_for_task(uid : Int64, *, timeout : Time::Span = self.timeout, poll_interval : Time::Span = 100.milliseconds, &)
      start = Time.monotonic
      while Time.monotonic - start < timeout
        fetched = tasks.get(uid)
        if fetched
          case fetched.status
          in .enqueued?, .processing?
            sleep poll_interval
          in .succeeded?, .failed?, .canceled?
            return fetched
          end
        else
          raise ArgumentError.new("No task with UID #{uid}")
        end
      end

      # We've exceeded the timeout, so we yield to the block and return the result
      yield
    end

    def tasks
      Tasks.new self
    end

    class TaskTimeout < Error
    end
  end
end

require "./documents"
require "./indexes"
require "./tasks"
require "./multi_search"
require "./index_client"
require "./api"

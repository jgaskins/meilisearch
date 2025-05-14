require "./resource"
require "./task"

module Meilisearch
  struct Batch < Resource
    # include JSON::Serializable::Unmapped

    field uid : Int64
    field details : Task::Details
    field progress : Progress?
    field stats : Stats
    field duration : Time::Span?, converter: Meilisearch::DurationConverter
    field started_at : Time?
    field finished_at : Time?

    struct Progress < Resource
      field steps : Array(Step)
      field percentage : Float64

      struct Step < Resource
        field current_step : String
        field finished : Int64
        field total : Int64
      end
    end

    struct Stats < Resource
      field total_nb_tasks : Int64
      field status : Hash(Task::Status, Int64)
      field types : Hash(Task::Type, Int64)
      field index_uids : Hash(String, Int64)
      field progress_trace : Hash(String, Time::Span), converter: Meilisearch::Batch::Stats::ProgressTraceConverter do
        {} of String => Time::Span
      end
      field write_channel_congestion : WriteChannelCongestion?
      field internal_database_sizes : Hash(String, String)?

      struct WriteChannelCongestion < Resource
        getter attempts : Int64
        getter blocking_attempts : Int64
        getter blocking_ratio : Float64
      end

      # :nodoc:
      module ProgressTraceConverter
        extend self

        def from_json(json : ::JSON::PullParser) : Hash(String, Time::Span)
          hash = {} of String => Time::Span
          json.read_object do |key|
            string = json.read_string
            magnitude = string.to_f(strict: false)
            last_digit_index = string.size.times do |index|
              char = string[-index - 1]
              if char.number?
                break string.size - index
              end
            end
            if last_digit_index.nil?
              raise Exception.new("Could not parse time duration from #{string.inspect}")
            end
            duration = case string[last_digit_index + 1..]
                       when "ns" then magnitude.nanoseconds
                       when "µs" then magnitude.microseconds
                       when "ms" then magnitude.milliseconds
                       when "s"  then magnitude.seconds
                       when "m"  then magnitude.minutes
                       when "h"  then magnitude.hours
                       when "d"  then magnitude.days
                       else
                         raise Exception.new("Could not parse time duration from #{string.inspect}")
                       end

            hash[key] = duration
          end
          hash
        end
      end
    end
  end
end

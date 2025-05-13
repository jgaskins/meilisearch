require "./resource"

module Meilisearch
  # The basic building block of a task. Tasks that are the result of API
  # operations are generally `TaskResult`s and fetching a task from the Task API
  # returns a `Task` subtype.
  abstract struct BasicTask < Resource
    field index_uid : String?
    field status : Task::Status
    field type : Task::Type
    field enqueued_at : Time
  end

  struct TaskResult < BasicTask
    field task_uid : Int64
  end

  abstract struct Task < BasicTask
    field uid : Int64
    field batch_uid : Int64?
    field batch_uids : JSON::Any?
    field canceled_by : Int64?
    field error : Error?
    field duration : Time::Span?, converter: Meilisearch::DurationConverter
    field started_at : Time?
    field finished_at : Time?

    use_json_discriminator "type", {
      indexCreation:            IndexCreation,
      indexUpdate:              IndexUpdate,
      indexDeletion:            IndexDeletion,
      indexSwap:                IndexSwap,
      documentAdditionOrUpdate: DocumentAdditionOrUpdate,
      documentDeletion:         DocumentDeletion,
      settingsUpdate:           SettingsUpdate,
      dumpCreation:             DumpCreation,
      taskCancelation:          TaskCancelation,
      taskDeletion:             TaskDeletion,
      snapshotCreation:         SnapshotCreation,
    }

    enum Status
      ENQUEUED
      PROCESSING
      SUCCEEDED
      FAILED
      CANCELED

      def self.from_json_object_key?(key : String)
        parse? key
      end
    end

    enum Type
      IndexCreation
      IndexUpdate
      IndexDeletion
      IndexSwap
      DocumentAdditionOrUpdate
      DocumentDeletion
      SettingsUpdate
      DumpCreation
      TaskCancelation
      TaskDeletion
      SnapshotCreation

      def self.from_json_object_key?(key : String)
        parse? key
      end
    end

    abstract struct Details < Resource
      def self.new(json : ::JSON::PullParser)
        location = json.location
        json = json.read_raw

        {% for type in @type.subclasses %}
          begin
            return {{type}}.from_json(json)
          rescue ex
          end
        {% end %}

        raise ::JSON::SerializableError.new("Cannot parse #{self} from #{json}", name, "details", *location, nil)
      end
    end

    macro details
      field! details : Details

      struct Details < Meilisearch::Task::Details
        {{yield}}
      end
    end

    struct DocumentAdditionOrUpdate < self
      details do
        field received_documents : Int64
        field indexed_documents : Int64?
      end
    end

    struct DocumentDeletion < self
      details do
        field provided_ids : Int64?
        field original_filter : JSON::Any?
        field deleted_documents : Int64?
      end
    end

    struct IndexCreation < self
      details do
        field primary_key : String?
      end
    end

    struct IndexUpdate < self
      details do
        field primary_key : String?
      end
    end

    struct IndexDeletion < self
      details do
        field deleted_documents : Int64?
      end
    end

    struct IndexSwap < self
      details do
        # TODO: Update the type to a concrete type
        field swaps : JSON::Any?
      end
    end

    struct SettingsUpdate < self
      details do
        private alias Data = JSON::Any?
        private alias List = Array(Data)

        field ranking_rules : Data
        field filterable_attributes : List { List.new }
        field distinct_attribute : Data
        field searchable_attributes : List { List.new }
        field displayed_attributes : List { List.new }
        field sortable_attributes : List { List.new }
        field stop_words : List { List.new }
        field synonyms : List { List.new }
        field typo_tolerance : Data
        field pagination : Data
        field faceting : Data
      end
    end

    struct DumpCreation < self
      details do
        field dump_uid : String?
      end
    end

    struct TaskCancelation < self
      details do
        field matched_tasks : Int64
        field canceled_tasks : Int64?
        field original_filter : JSON::Any? # Probably a string
      end
    end

    struct TaskDeletion < self
      details do
        field matched_tasks : Int64
        field canceled_tasks : Int64?
        field original_filter : JSON::Any? # Probably a string
      end
    end

    struct SnapshotCreation < self
      # No details
      details {}
    end

    struct Error < Resource
      field message : String
      field code : String
      field type : String
      field link : URI
    end
  end
end

require "./task"

module Meilisearch
  struct Tasks < API
    def get(uid : Int64)
      response http.get("/tasks/#{uid}"), as: Task
    end

    def get(
      *,
      uids : String | Array(String) | Nil = nil,
      batch_uids : String | Array(String) | Nil = nil,
      statuses : Task::Status | Array(Task::Status) | Nil = nil,
      types : Task::Type | Array(Task::Type) | Nil = nil,
      index_uids : String | Array(String) | Nil = nil,
      limit : Int32? = nil,
      from last_task_uid : Int64,
      reverse : Bool? = nil,
      before_enqueued_at : Time? = nil,
      before_started_at : Time? = nil,
      before_finished_at : Time? = nil,
      after_enqueued_at : Time? = nil,
      after_started_at : Time? = nil,
      after_finished_at : Time? = nil,
    )
      response
    end
  end
end

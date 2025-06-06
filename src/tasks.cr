require "./task"
require "./list"

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
      from last_task_uid : Int64? = nil,
      reverse : Bool? = nil,
      enqueued_at : Range? = nil,
      started_at : Range? = nil,
      finished_at : Range? = nil,
    )
      get(
        **pass(
          uids,
          batch_uids,
          statuses,
          types,
          index_uids,
          limit,
          reverse,
        ),
        before_enqueued_at: enqueued_at.try(&.begin),
        after_enqueued_at: enqueued_at.try(&.end),
        before_started_at: started_at.try(&.begin),
        after_started_at: started_at.try(&.end),
        before_finished_at: finished_at.try(&.begin),
        after_finished_at: finished_at.try(&.end),
        from: last_task_uid,
      )
    end

    def get(
      *,
      uids : Int64 | Array(Int64) | Nil = nil,
      batch_uids : String | Array(String) | Nil = nil,
      statuses : Task::Status | Array(Task::Status) | Nil = nil,
      types : Task::Type | Array(Task::Type) | Nil = nil,
      index_uids : String | Array(String) | Nil = nil,
      limit : Int32? = nil,
      from last_task_uid : Int64? = nil,
      reverse : Bool? = nil,
      before_enqueued_at : Time? = nil,
      before_started_at : Time? = nil,
      before_finished_at : Time? = nil,
      after_enqueued_at : Time? = nil,
      after_started_at : Time? = nil,
      after_finished_at : Time? = nil,
    )
      params = URI::Params.new
      params["uids"] = uids.join(',') if uids
      params["batchUids"] = batch_uids.join(',') if batch_uids
      params["indexUids"] = index_uids.join(',') if index_uids
      params["statuses"] = statuses.map(&.to_s.underscore).join(',') if statuses
      params["limit"] = limit if limit
      params["from"] = last_task_uid if last_task_uid
      params["reverse"] = reverse if reverse
      params["beforeEnqueuedAt"] = before_enqueued_at if before_enqueued_at
      params["beforeStartedAt"] = before_started_at if before_started_at
      params["beforeFinishedAt"] = before_finished_at if before_finished_at
      params["afterEnqueuedAt"] = before_enqueued_at if before_enqueued_at
      params["afterStartedAt"] = before_started_at if before_started_at
      params["afterFinishedAt"] = before_finished_at if before_finished_at

      response http.get("/tasks?#{params}"), as: List(Task)
    end
  end
end

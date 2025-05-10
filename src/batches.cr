require "./api"

require "./batch"

module Meilisearch
  struct Batches < API
    def list(
      *,
      uids : Array(Int64)? = nil,
      batch_uids : Array(Int64)? = nil,
      index_uids : Array(String)? = nil,
      statuses : Array(Task::Status)? = nil,
      types : Arary(Task::Tyoe)? = nil,
      limit : Int? = nil,
      from : Int? = nil,
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
      params["statuses"] = statuses.map(&.underscore).join(',') if statuses
      params["types"] = types.map(&.underscore).join(',') if types
      params["limit"] = limit.to_s if limit
      params["from"] = from.to_s if from
      params["reverse"] = reverse.to_s if reverse
      params["before_enqueued_at"] = before_enqueued_at.to_rfc_3339(fraction_digits: 9) if before_enqueued_at
      params["before_started_at"] = before_started_at.to_rfc_3339(fraction_digits: 9) if before_started_at
      params["before_finished_at"] = before_finished_at.to_rfc_3339(fraction_digits: 9) if before_finished_at
      params["after_enqueued_at"] = after_enqueued_at.to_rfc_3339(fraction_digits: 9) if after_enqueued_at
      params["after_started_at"] = after_started_at.to_rfc_3339(fraction_digits: 9) if after_started_at
      params["after_finished_at"] = after_finished_at.to_rfc_3339(fraction_digits: 9) if after_finished_at
      response(
        http.get("/batches?#{params}"),
        as: List(Batch)
      )
    end

    struct List(T) < Resource
      include Enumerable(T)

      field results : Array(T)
      field limit : Int64
      field total : Int64
      field from : Int64
      field next : Int64?

      delegate each, to: results
    end
  end
end

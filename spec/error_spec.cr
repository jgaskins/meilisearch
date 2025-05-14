require "./spec_helper"

require "../src/client"

describe Meilisearch::Exception do
  it "returns an error-code-specific exception" do
    error = Meilisearch::Error.from_json({
      message: "oops!",
      code:    "index_not_found",
      type:    "invalid_request",
      link:    "https://www.meilisearch.com/docs/reference/lol-idk",
    }.to_json)

    Meilisearch::Exception.new(error)
      .should be_a Meilisearch::Exception::IndexNotFound
  end
end

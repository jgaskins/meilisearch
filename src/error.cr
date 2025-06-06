require "json"
require "uri/json"

module Meilisearch
  struct Error
    include JSON::Serializable

    getter message : String
    getter code : Code
    getter type : Type
    getter link : URI

    enum Code
      # A key with this uid already exists.
      APIKeyAlreadyExists

      # The requested API key could not be found.
      APIKeyNotFound

      # The request is invalid, check the error message for more information.
      BadRequest

      # The requested batch does not exist. Please ensure that you are using the correct uid.
      BatchNotFound

      # The requested database has reached its maximum size.
      DatabaseSizeLimitReached

      # A document exceeds the maximum limit of 65,535 fields.
      DocumentFieldsLimitReached

      # The requested document can’t be retrieved. Either it doesn’t exist, or the database was left in an inconsistent state.
      DocumentNotFound

      # An error occurred during the dump creation process. The task was aborted.
      DumpProcessFailed

      # The /facet-search route has been queried while the facetSearch index setting is set to false.
      FacetSearchDisabled

      # You have tried using an experimental feature without activating it.
      FeatureNotEnabled

      # The actions field of an API key cannot be modified.
      ImmutableAPIKeyActions

      # The createdAt field of an API key cannot be modified.
      ImmutableAPIKeyCreatedAt

      # The expiresAt field of an API key cannot be modified.
      ImmutableAPIKeyExpiresAt

      # The indexes field of an API key cannot be modified.
      ImmutableAPIKeyIndexes

      # The key field of an API key cannot be modified.
      ImmutableAPIKeyKey

      # The uid field of an API key cannot be modified.
      ImmutableAPIKeyUid

      # The updatedAt field of an API key cannot be modified.
      ImmutableAPIKeyUpdatedAt

      # The uid field of an index cannot be modified.
      ImmutableIndexUid

      # The updatedAt field of an index cannot be modified.
      ImmutableIndexUpdatedAt

      # An index with this uid already exists, check out our guide on index creation.
      IndexAlreadyExists

      # An error occurred while trying to create an index, check out our guide on index creation.
      IndexCreationFailed

      # An index with this uid was not found, check out our guide on index creation.
      IndexNotFound

      # The requested index already has a primary key that cannot be changed.
      IndexPrimaryKeyAlreadyExists

      # Primary key inference failed because the received documents contain multiple fields ending with id. Use the update index endpoint to manually set a primary key.
      IndexPrimaryKeyMultipleCandidatesFound

      # Meilisearch experienced an internal error. Check the error message, and open an issue if necessary.
      Internal

      # The requested resources are protected with an API key. The provided API key is invalid. Read more about it in our security tutorial.
      InvalidAPIKey

      # The actions field for the provided API key resource is invalid. It should be an array of strings representing action names.
      InvalidAPIKeyActions

      # The description field for the provided API key resource is invalid. It should either be a string or set to null.
      InvalidAPIKeyDescription

      # The expiresAt field for the provided API key resource is invalid. It should either show a future date or datetime in the RFC 3339 format or be set to null.
      InvalidAPIKeyExpiresAt

      # The indexes field for the provided API key resource is invalid. It should be an array of strings representing index names.
      InvalidAPIKeyIndexes

      # The limit parameter is invalid. It should be an integer.
      InvalidAPIKeyLimit

      # The given name is invalid. It should either be a string or set to null.
      InvalidAPIKeyName

      # The offset parameter is invalid. It should be an integer.
      InvalidAPIKeyOffset

      # The given uid is invalid. The uid must follow the uuid v4 format.
      InvalidAPIKeyUid

      # The value passed to attributesToSearchOn is invalid. attributesToSearchOn accepts an array of strings indicating document attributes. Attributes given to attributesToSearchOn must be present in the searchableAttributes list.
      InvalidSearchAttributesToSearchOn

      # The Content-Type header is not supported by Meilisearch. Currently, Meilisearch only supports JSON, CSV, and NDJSON.
      InvalidContentType

      # The csvDelimiter parameter is invalid. It should either be a string or a single ASCII character.
      InvalidDocumentCsvDelimiter

      # The provided document identifier does not meet the format requirements. A document identifier must be of type integer or string, composed only of alphanumeric characters (a-z A-Z 0-9), hyphens (-), and underscores (_).
      InvalidDocumentId

      # The fields parameter is invalid. It should be a string.
      InvalidDocumentFields

      # This error occurs if:
      # - The filter parameter is invalid
      #   - It should be a string, array of strings, or array of array of strings for the get documents with POST endpoint
      #   - It should be a string for the get documents with GET endpoint
      # - The attribute used for filtering is not defined in the filterableAttributes list
      # - The filter expression has a missing or invalid operator. Read more about our supported operators
      InvalidDocumentFilter

      # The limit parameter is invalid. It should be an integer.
      InvalidDocumentLimit

      # The offset parameter is invalid. It should be an integer.
      InvalidDocumentOffset

      # The provided _geo field of one or more documents is invalid. Meilisearch expects _geo to be an object with two fields, lat and lng, each containing geographic coordinates expressed as a string or floating point number. Read more about _geo and how to troubleshoot it in our dedicated guide.
      InvalidDocumentGeoField

      # The attribute used for the facetName field is either not a string or not defined in the filterableAttributes list.
      InvalidFacetSearchFacetName

      # The provided value for facetQuery is invalid. It should either be a string or null.
      InvalidFacetSearchFacetQuery

      # The limit parameter is invalid. It should be an integer.
      InvalidIndexLimit

      # The offset parameter is invalid. It should be an integer.
      InvalidIndexOffset

      # There is an error in the provided index format, check out our guide on index creation.
      InvalidIndexUid

      # The primaryKey field is invalid. It should either be a string or set to null.
      InvalidIndexPrimaryKey

      # A multi-search query includes federationOptions but the top-level federation object is null or missing.
      InvalidMultiSearchQueryFederated

      # A multi-search query contains page, hitsPerPage, limit or offset, but the top-level federation object is not null.
      InvalidMultiSearchQueryPagination

      # federationOptions.queryPosition is not a positive integer.
      InvalidMultiSearchQueryPosition

      # A multi-search query contains a negative value for federated.weight.
      InvalidMultiSearchWeight

      # Two or more queries in a multi-search request have incompatible results.
      InvalidMultiSearchQueriesRankingRules

      # federation.facetsByIndex.<INDEX_NAME> contains a value that is not in the filterable attributes list.
      InvalidMultiSearchFacets

      # federation.mergeFacets.sortFacetValuesBy is not a string or doesn’t have one of the allowed values.
      InvalidMultiSearchSortFacetValuesBy

      # A query in the queries array contains facets when federation is present and non-null.
      InvalidMultiSearchQueryFacets

      # federation.mergeFacets  is not an object or contains unexpected fields.
      InvalidMultiSearchMergeFacets

      # federation.mergeFacets.maxValuesPerFacet is not a positive integer.
      InvalidMultiSearchMaxValuesPerFacet

      # Two or more indexes have a different faceting.sortFacetValuesBy for the same requested facet.
      InvalidMultiSearchFacetOrder

      # facetsByIndex is not an object or contains unknown fields.
      InvalidMultiSearchFacetsByIndex

      # federationOptions.remote is not network.self and is not a key in network.remotes.
      InvalidMultiSearchRemote

      # The network object contains a self that is not a string or null.
      InvalidNetworkSelf

      # The network object contains a remotes that is not an object or null.
      InvalidNetworkRemotes

      # One of the remotes in the network object contains a url that is not a string.
      InvalidNetworkUrl

      # One of the remotes in the network object contains a searchApiKey that is not a string or null.
      InvalidNetworkSearchAPIKey

      # The attributesToCrop parameter is invalid. It should be an array of strings, a string, or set to null.
      InvalidSearchAttributesToCrop

      # The attributesToHighlight parameter is invalid. It should be an array of strings, a string, or set to null.
      InvalidSearchAttributesToHighlight

      # The attributesToRetrieve parameter is invalid. It should be an array of strings, a string, or set to null.
      InvalidSearchAttributesToRetrieve

      # The cropLength parameter is invalid. It should be an integer.
      InvalidSearchCropLength

      # The cropMarker parameter is invalid. It should be a string or set to null.
      InvalidSearchCropMarker

      # embedder is invalid. It should be a string corresponding to the name of a configured embedder.
      InvalidSearchEmbedder

      # This error occurs if:
      # - The facets parameter is invalid. It should be an array of strings, a string, or set to null
      # - The attribute used for faceting is not defined in the filterableAttributes list
      InvalidSearchFacets

      # This error occurs if:
      # - The syntax for the filter parameter is invalid
      # - The attribute used for filtering is not defined in the filterableAttributes list
      # - A reserved keyword like _geo, _geoDistance, or _geoPoint is used as a filter
      InvalidSearchFilter

      # The highlightPostTag parameter is invalid. It should be a string.
      InvalidSearchHighlightPostTag

      # The highlightPreTag parameter is invalid. It should be a string.
      InvalidSearchHighlightPreTag

      # The hitsPerPage parameter is invalid. It should be an integer.
      InvalidSearchHitsPerPage

      # The hybrid parameter is neither null nor an object, or it is an object with unknown keys.
      InvalidSearchHybridQuery

      # The limit parameter is invalid. It should be an integer.
      InvalidSearchLimit

      # The locales parameter is invalid.
      InvalidSearchLocales

      # The embedders index setting value is invalid.
      InvalidSettingsEmbedder

      # The embedders index setting value is invalid.
      InvalidSettingsEmbedders

      # The facetSearch index setting value is invalid.
      InvalidSettingsFacetSearch

      # The localizedAttributes index setting value is invalid.
      InvalidSettingsLocalizedAttributes

      # The matchingStrategy parameter is invalid. It should either be set to last or all.
      InvalidSearchMatchingStrategy

      # The offset parameter is invalid. It should be an integer.
      InvalidSearchOffset

      # The prefixSearch index setting value is invalid.
      InvalidSettingsPrefixSearch

      # The page parameter is invalid. It should be an integer.
      InvalidSearchPage

      # The q parameter is invalid. It should be a string or set to null
      InvalidSearchQ

      # The rankingScoreThreshold in a search or multi-search request is not a number between 0.0 and 1.0.
      InvalidSearchRankingScoreThreshold

      # The showMatchesPosition parameter is invalid. It should either be a boolean or set to null.
      InvalidSearchShowMatchesPosition

      # This error occurs if:
      # - The syntax for the sort parameter is invalid
      # - The attribute used for sorting is not defined in the sortableAttributes list or the sort ranking rule is missing from the settings
      # - A reserved keyword like _geo, _geoDistance, _geoRadius, or _geoBoundingBox is used as a filter
      InvalidSearchSort

      # The value of displayed attributes is invalid. It should be an empty array, an array of strings, or set to null.
      InvalidSettingsDisplayedAttributes

      # The value of distinct attributes is invalid. It should be a string or set to null.
      InvalidSettingsDistinctAttribute

      # The value provided for the sortFacetValuesBy object is incorrect. The accepted values are alpha or count.
      InvalidSettingsFacetingSortFacetValuesBy

      # The value for the maxValuesPerFacet field is invalid. It should either be an integer or set to null.
      InvalidSettingsFacetingMaxValuesPerFacet

      # The value of filterable attributes is invalid. It should be an empty array, an array of strings, or set to null.
      InvalidSettingsFilterableAttributes

      # The value for the maxTotalHits field is invalid. It should either be an integer or set to null.
      InvalidSettingsPagination

      # This error occurs if:
      # - The settings payload has an invalid format
      # - A non-existent ranking rule is specified
      # - A custom ranking rule is malformed
      # - A reserved keyword like _geo, _geoDistance, _geoRadius, _geoBoundingBox, or _geoPoint is used as a custom ranking rule
      InvalidSettingsRankingRules

      # The value of searchable attributes is invalid. It should be an empty array, an array of strings or set to null.
      InvalidSettingsSearchableAttributes

      # The specified value for `searchCutoffMs is invalid. It should be an integer indicating the cutoff in milliseconds.
      InvalidSettingsSearchCutoffMs

      # The value of sortable attributes is invalid. It should be an empty array, an array of strings or set to null.
      InvalidSettingsSortableAttributes

      # The value of stop words is invalid. It should be an empty array, an array of strings or set to null.
      InvalidSettingsStopWords

      # The value of the synonyms is invalid. It should either be an object or set to null.
      InvalidSettingsSynonyms

      # This error occurs if:
      # - The enabled field is invalid. It should either be a boolean or set to null
      # - The disableOnAttributes field is invalid. It should either be an array of strings or set to null
      # - The disableOnWords field is invalid. It should either be an array of strings or set to null
      # - The minWordSizeForTypos field is invalid. It should either be an integer or set to null
      # - The value of either oneTypo or twoTypos is invalid. It should either be an integer or set to null
      InvalidSettingsTypoTolerance

      # The provided target document identifier is invalid. A document identifier can be of type integer or string, only composed of alphanumeric characters (a-z A-Z 0-9), hyphens (-) and underscores (_).
      InvalidSimilarId

      # Meilisearch could not find the target document. Make sure your target document identifier corresponds to a document in your index.
      NotFoundSimilarId

      # attributesToRetrieve is invalid. It should be an array of strings, a string, or set to null.
      InvalidSimilarAttributesToRetrieve

      # embedder is invalid. It should be a string corresponding to the name of a configured embedder.
      InvalidSimilarEmbedder

      # filter is invalid or contains a filter expression with a missing or invalid operator. Filter expressions must be a string, array of strings, or array of array of strings for the POST endpoint. It must be a string for the GET endpoint.
      # Meilisearch also throws this error if the attribute used for filtering is not defined in the filterableAttributes list.
      InvalidSimilarFilter

      # limit is invalid. It should be an integer.
      InvalidSimilarLimit

      # offset is invalid. It should be an integer.
      InvalidSimilarOffset

      # ranking_score is invalid. It should be a boolean.
      InvalidSimilarShowRankingScore

      # ranking_score_details is invalid. It should be a boolean.
      InvalidSimilarShowRankingScoreDetails

      # The rankingScoreThreshold in a similar documents request is not a number between 0.0 and 1.0.
      InvalidSimilarRankingScoreThreshold

      # The database is in an invalid state. Deleting the database and re-indexing should solve the problem.
      InvalidState

      # The data.ms folder is in an invalid state. Your b file is corrupted or the data.ms folder has been replaced by a file.
      InvalidStoreFile

      # The indexes used in the indexes array for a swap index request have been declared multiple times. You must declare each index only once.
      InvalidSwapDuplicateIndexFound

      # This error happens if:
      # - The payload doesn’t contain exactly two index uids for a swap operation
      # - The payload contains an invalid index name in the indexes array
      InvalidSwapIndexes

      # The afterEnqueuedAt query parameter is invalid.
      InvalidTaskAfterEnqueuedAt

      # The afterFinishedAt query parameter is invalid.
      InvalidTaskAfterFinishedAt

      # The afterStartedAt query parameter is invalid.
      InvalidTaskAfterStartedAt

      # The beforeEnqueuedAt query parameter is invalid.
      InvalidTaskBeforeEnqueuedAt

      # The beforeFinishedAt query parameter is invalid.
      InvalidTaskBeforeFinishedAt

      # The beforeStartedAt query parameter is invalid.
      InvalidTaskBeforeStartedAt

      # The canceledBy query parameter is invalid. It should be an integer. Multiple uids should be separated by commas (,).
      InvalidTaskCanceledBy

      # The indexUids query parameter contains an invalid index uid.
      InvalidTaskIndexUids

      # The limit parameter is invalid. It must be an integer.
      InvalidTaskLimit

      # The requested task status is invalid. Please use one of the possible values.
      InvalidTaskStatuses

      # The requested task type is invalid. Please use one of the possible values.
      InvalidTaskTypes

      # The uids query parameter is invalid.
      InvalidTaskUids

      # This error generally occurs when the host system has no space left on the device or when the database doesn’t have read or write access.
      IoError

      # Primary key inference failed as the received documents do not contain any fields ending with id. Manually designate the primary key, or add some field ending with id to your documents.
      IndexPrimaryKeyNoCandidateFound

      # The Content-Type header does not match the request body payload format or the format is invalid.
      MalformedPayload

      # The actions field is missing from payload.
      MissingAPIKeyActions

      # The expiresAt field is missing from payload.
      MissingAPIKeyExpiresAt

      # The indexes field is missing from payload.
      MissingAPIKeyIndexes

      # This error happens if:
      # - The requested resources are protected with an API key that was not provided in the request header. Check our security tutorial for more information
      # - You are using the wrong authorization header for your version. v0.24 and below use X-MEILI-API-KEY: apiKey, whereas v0.25 and above use Authorization: Bearer apiKey
      MissingAuthorizationHeader

      # The payload does not contain a Content-Type header. Currently, Meilisearch only supports JSON, CSV, and NDJSON.
      MissingContentType

      # This payload is missing the filter field.
      MissingDocumentFilter

      # A document does not contain any value for the required primary key, and is thus invalid. Check documents in the current addition for the invalid ones.
      MissingDocumentId

      # The payload is missing the uid field.
      MissingIndexUid

      # The facetName parameter is required.
      MissingFacetSearchFacetName

      # You need to set a master key before you can access the /keys route. Read more about setting a master key at launch in our security tutorial.
      MissingMasterKey

      # One of the remotes in the network object does not contain the url field.
      MissingNetworkUrl

      # The Content-Type header was specified, but no request body was sent to the server or the request body is empty.
      MissingPayload

      # The index swap payload is missing the indexes object.
      MissingSwapIndexes

      # The cancel tasks and delete tasks endpoints require one of the available query parameters.
      MissingTaskFilters

      # This error occurs if:
      # - The host system partition reaches its maximum capacity and can no longer accept writes
      # - The tasks queue reaches its limit and can no longer accept writes. You can delete tasks using the delete tasks endpoint to continue write operations
      NoSpaceLeftOnDevice

      # The requested resources could not be found.
      NotFound

      # The payload sent to the server was too large. Check out this guide to customize the maximum payload size accepted by Meilisearch.
      PayloadTooLarge

      # The requested task does not exist. Please ensure that you are using the correct uid.
      TaskNotFound

      # Indexing a large batch of documents, such as a JSON file over 3.5GB in size, can result in Meilisearch opening too many file descriptors. Depending on your machine, this might reach your system’s default resource usage limits and trigger the too_many_open_files error. Use ulimit or a similar tool to increase resource consumption limits before running Meilisearch. For example, call ulimit -Sn 3000 in a UNIX environment to raise the number of allowed open file descriptors to 3000.
      TooManyOpenFiles

      # You have reached the limit of concurrent search requests. You may configure it by relaunching your instance and setting a higher value to --experimental-search-queue-size.
      TooManySearchRequests

      # The document exists in store, but there was an error retrieving it. This probably comes from an inconsistent state in the database.
      UnretrievableDocument

      # Error while generating embeddings.
      VectorEmbeddingError

      # The remote instance answered with a response that this instance could not use as a federated search response.
      RemoteBadResponse

      # The remote instance answered with 400 BAD REQUEST.
      RemoteBadRequest

      # There was an error while sending the remote federated search request.
      RemoteCouldNotSendRequest

      # The remote instance answered with 403 FORBIDDEN or 401 UNAUTHORIZED to this instance’s request. The configured search API key is either missing, invalid, or lacks the required search permission.
      RemoteInvalidAPIKey

      # The remote instance answered with 500 INTERNAL ERROR.
      RemoteRemoteError

      # The proxy did not answer in the allocated time.
      RemoteTimeout
    end

    enum Type
      # This is due to an error in the user input. It is accompanied by the HTTP code `4xx`.
      InvalidRequest

      # This is due to machine or configuration constraints. It is accompanied by the HTTP code `5xx`.
      Internal

      # This type of error is related to authentication and authorization. It is accompanied by the HTTP code `4xx`.
      Auth

      # This indicates your system has reached or exceeded its limit for disk size, index size, open files, or the database doesn’t have read or write access. It is accompanied by the HTTP code `5xx`.
      System
    end
  end

  class Exception < ::Exception
    getter error : Error?

    def self.new(error : Error, *, cause : Exception? = nil)
      ERROR_CODE_MAP.fetch(error.code, self).new(
        message: error.message,
        error: error,
        cause: cause,
      )
    end

    def initialize(message, @error = nil, *, cause : Exception? = nil)
      super message, cause: cause
    end

    private ERROR_CODE_MAP = {} of Error::Code => Exception.class

    {% for member in Error::Code.constants %}
      class {{member}} < self
      end

      ERROR_CODE_MAP[Error::Code::{{member}}] = {{member}}
    {% end %}
  end
end

def raise(error : Meilisearch::Error)
  raise Meilisearch::Exception.new(error)
end

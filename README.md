# meilisearch

This shard allows you to use the [Meilisearch search database](https://www.meilisearch.com/docs) from Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     meilisearch:
       github: jgaskins/meilisearch
   ```

2. Run `shards install`

## Usage

Make sure the shard is loaded and instantiate your `Meilisearch::Client`:

```crystal
require "meilisearch"

meilisearch = Meilisearch::Client.new(
  # Defaults to the `MEILISEARCH_API_KEY` env var
  api_key: "your-api-key-here",
  # Defaults to `http://localhost:7700`
  uri: URI.parse("https://your-meilisearch-host:7700/"),
)
```

### Create an index

```crystal
# Create an index asynchronously, returns a `Meilisearch::Task`
meilisearch.indexes.create "index-name", primary_key: "id"

# Create an index synchronously using the `!` form of the method,
# returns a `Meilisearch::Index`.
meilisearch.indexes.create! "index-name", primary_key: "id"
```

The `primary_key` argument is optional. If you don't set it here, the index will be created without a primary key.

### Add documents to an index

Documents in Meilisearch are "upserted", meaning they're either updated or inserted depending on the value of the index's `primary_key`. You can upsert a document by calling `upsert` on the `documents` API (also available abbreviated as `docs`)

```crystal
meilisearch.docs.upsert "posts", PostQuery.new.to_a
```

The `documents`

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/jgaskins/meilisearch/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Jamie Gaskins](https://github.com/jgaskins) - creator and maintainer

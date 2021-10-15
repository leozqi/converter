## Parsing config.json

Parsing JSON configuration file: (This should be done everytime at startup)

1. Iterate over base array `Json.Array` for `Json.Object`.
2. For each `Json.Object`, create a new ConvertHandle() with the Json.Object as
param.
3. Repeat.

In ConvertHandle():

1. Get basic metadata:
    * `from` field: a mimetype of the input file's type
    * `to` field: a mimetype of the output file's type
    * `check`: a command to check for whether the CLI tool exists before
2. For `commands`, iterate within the array for all `string` members
    * For each string (or command), add them into the `commands[]` field of
      ConvertHandle

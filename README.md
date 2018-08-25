# nim-overpass

- [OpenStreetMap](https://openstreetmap.org) [Overpass](https://overpass-turbo.eu) API Lib, [Async & Sync](https://github.com/juancarlospaco/nim-overpass/blob/master/src/overpass.nim#L74), with & without SSL, [command line App (50Kb)](https://github.com/juancarlospaco/nim-overpass/releases).

![OpenStreetMap](https://raw.githubusercontent.com/juancarlospaco/nim-overpass/master/osm.jpg)


# Install

- `nimble install overpass`


# Use

- `./overpass "node(1422314245);out;"`

# Requisites

- None.


# API

`get*(this: OSM | AsyncOSM, query: string, api_url = api_main0)`

- `this` is `OSM(timeout=int8)` for Synchronous code or `AsyncOSM(timeout=int8)` for Asynchronous code.
- `query` is an overpass query, `string` type, required.
- `api_url` is an overpass HTTP API URL, `string` type, optional.


# FAQ

- How to Edit the OpenStreetMap using this lib ?.

You can not, Overpass is a read-only OpenStreetMap API, but optimized for read speed.

- This works without SSL ?.

Yes.

- This works with SSL ?.

Yes.

- This works with Asynchronous code ?.

Yes.

- This works with Synchronous code ?.

Yes.

- How do I build the Query string ?.

Use Nims [builtin XML module](https://nim-lang.org/docs/xmldom.html) or [FMT strings module](https://nim-lang.org/docs/strformat.html).

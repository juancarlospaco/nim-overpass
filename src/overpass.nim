## Nim-Overpass
## ============
##
## OpenStreetMap Overpass API Lib, Async & Sync, with & without SSL, command line App.
##
## Install
## -------
##
## ``nimble install overpass``
##
## Use
## ---
##
## ``./overpass "node(1422314245);out;"``
##
## API
## ---
##
## ``get*(this: OSM | AsyncOSM, query: string, api_url = api_main0)``
##
## - ``this`` is ``OSM(timeout=int8)`` for Synchronous code or ``AsyncOSM(timeout=int8)`` for Asynchronous code.
## - ``query`` is an overpass query, ``string`` type, required.
## - ``api_url`` is an overpass HTTP API URL, ``string`` type, optional.

import
  asyncdispatch, json, httpclient, strformat, strutils, times, xmldomparser,
  xmldom, terminal, random, os

when defined(ssl):  # Works with SSL.
  const
    api_main0* = "https://overpass-api.de/api/interpreter"           ## Main Official OverPass API.
    api_main1* = "https://lz4.overpass-api.de/api/interpreter"       ## Main OverPass API Alternative.
    api_main2* = "https://z.overpass-api.de/api/interpreter"         ## Main OverPass API Alternative.
    api_swiss* = "https://overpass.osm.ch/api/interpreter"           ## Swiss-only OverPass API Alternative.
    api_irish* = "https://overpass.openstreetmap.ie/api/interpreter" ## Irish-only OverPass API Alternative.
    api_kumis* = "https://overpass.openstreetmap.ie/api/interpreter" ## Kumi Systems OverPass API Alternative.
    api_franc* = "https://api.openstreetmap.fr/api/interpreter"      ## France OverPass API Alternative.
else:  # Works without SSL.
  const
    api_main0* = "http://overpass-api.de/api/interpreter"           ## Main Official OverPass API.
    api_main1* = "http://lz4.overpass-api.de/api/interpreter"       ## Main OverPass API Alternative.
    api_main2* = "http://z.overpass-api.de/api/interpreter"         ## Main OverPass API Alternative.
    api_swiss* = "http://overpass.osm.ch/api/interpreter"           ## Swiss-only OverPass API Alternative.
    api_irish* = "http://overpass.openstreetmap.ie/api/interpreter" ## Irish-only OverPass API Alternative.
    api_kumis* = "http://overpass.openstreetmap.ie/api/interpreter" ## Kumi Systems OverPass API Alternative.
    api_franc* = "http://api.openstreetmap.fr/api/interpreter"      ## France OverPass API Alternative.

type
  OverpassBase*[HttpType] = object
    timeout*: int8
  OSM* = OverpassBase[HttpClient]            ##  Sync OpenStreetMap OverPass Client.
  AsyncOSM* = OverpassBase[AsyncHttpClient]  ## Async OpenStreetMap OverPass Client.

proc get*(this: OSM | AsyncOSM, query: string, api_url = api_main0): Future[string] {.multisync.} =
  ## Take an OverPass query and return an XML or JSON result, Asynchronously or Synchronously.
  let
    response =
      when this is AsyncOSM: await newAsyncHttpClient().get(api_url & "?data=" & query.strip) # Async.
      else: newHttpClient(timeout=this.timeout * 1000).get(api_url & "?data=" & query.strip)  # Sync.
  result = await response.body

when is_main_module:
  when defined(release):  # When release, its a command line app to make queries to OpenStreetMap.
    randomize()
    setBackgroundColor(bgBlack)
    setForegroundColor([fgRed, fgGreen, fgYellow, fgBlue, fgMagenta, fgCyan, fgWhite].rand)
    echo OSM(timeout: 99).get(query=paramStr(1))
  else:  # When not release, its an example of how to make queries to OpenStreetMap.
    let
      openstreetmap_client = OSM(timeout: 5)
      async_openstreetmap_client = AsyncOSM(timeout: 5)
    # Sync client.
    echo openstreetmap_client.get(query="node(1422314245);out;")
    echo openstreetmap_client.get(query="[out:json];node(507464799);out;")
    # Async client.
    proc test {.async.} = echo await async_openstreetmap_client.get(query="node(1422314245);out;")
    waitFor test()

## Nim-Overpass
## ============
##
## - OpenStreetMap Overpass API Lib, Async & Sync, with & without SSL, command line App.
##
## Install
## -------
##
## - ``nimble install overpass``
##
## Use
## ---
##
## - ``./overpass --color --lower --timeout=9 "node(1422314245)"``
##
## API
## ---
##
## - ``search*(this: Overpass | AsyncOverpass, query: string, api_url = api_main0)``
##
## - ``this`` is ``Overpass(timeout=byte)`` for Synchronous code or ``AsyncOverpass(timeout=byte)`` for Asynchronous code.
## - ``query`` is an overpass query, ``string`` type, required.
## - ``api_url`` is an overpass HTTP API URL, ``string`` type, optional.
import asyncdispatch, httpclient, strformat, strutils, httpcore, os, json

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
    timeout*: byte ## Timeout Seconds for API Calls, byte type, 0~255.
    proxy*: Proxy ## Network IPv4 / IPv6 Proxy support, Proxy type.
  Overpass* = OverpassBase[HttpClient]            ##  Sync OpenStreetMap OverPass Client.
  AsyncOverpass* = OverpassBase[AsyncHttpClient]  ## Async OpenStreetMap OverPass Client.

proc search*(this: Overpass | AsyncOverpass, query: string, api_url = api_main0): Future[JsonNode] {.multisync.} =
  ## Take an OverPass query and return JSON, Asynchronously or Synchronously.
  let
    cueri = "?data=[out:json];" & query.strip & ";out;"
    response =
      when this is AsyncOverpass:
        await newAsyncHttpClient(proxy = when declared(this.proxy): this.proxy else: nil).get(api_url & cueri) # Async.
      else:
        newHttpClient(timeout=this.timeout.int * 1000, proxy = when declared(this.proxy): this.proxy else: nil ).get(api_url & cueri)  # Sync.
  result = parseJson(await response.body)


when is_main_module and defined(release) and not defined(js):  # When release, its a command line app to make queries to OpenStreetMap.
  import parseopt, terminal, random
  var
    taimaout = 99.byte
    minusculas: bool
  for tipoDeClave, clave, valor in getopt():
    case tipoDeClave
    of cmdShortOption, cmdLongOption:
      case clave
      of "version":             quit("0.2.5", 0)
      of "license", "licencia": quit("MIT", 0)
      of "help", "ayuda":       quit("""./overpass --color --lower --timeout=9 "node(1422314245)" """, 0)
      of "minusculas", "lower": minusculas = true
      of "timeout":             taimaout = taimaout.byte # HTTTP Timeout.
      of "color":
        randomize()
        setBackgroundColor(bgBlack)
        setForegroundColor([fgRed, fgGreen, fgYellow, fgBlue, fgMagenta, fgCyan, fgWhite].rand)
    of cmdArgument:
      let
        clientito = Overpass(timeout: taimaout)
        resultadito = clientito.search(query=clave.strip.toLowerAscii).pretty
      if minusculas: echo resultadito.toLowerAscii else: echo resultadito
    of cmdEnd: quit("Wrong Parameters, see Help with --help", 1)


runnableExamples:  # This is an example of how to make queries to OpenStreetMap.
  import asyncdispatch, json

  # Sync client.
  let overpass_client = Overpass(timeout: 5, proxy: nil)
  echo overpass_client.search(query="node(1422314245)").pretty
  echo overpass_client.search(query="node(507464799)").pretty

  # Async client.
  proc test {.async.} =
    let
      async_overpass_client = AsyncOverpass(timeout: 5, proxy: nil)
      results = await async_overpass_client.search(query="node(1422314245)")
    echo results.pretty

  wait_for test()

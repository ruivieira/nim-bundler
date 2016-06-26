import sequtils, os, osproc

proc matches_extension(asset : string, extension: string) : bool =
  splitFile(asset)[2] == extension
proc is_css(asset : string) : bool = matches_extension(asset, ".css")
proc is_js(asset : string) : bool = matches_extension(asset, ".js")
proc is_coffee(asset : string) : bool = matches_extension(asset, ".coffee")

proc bundle*(assets: seq[string], dir : string, prefix: string) =
  echo "building " & dir & "/" & prefix & "[js,css]"
  # process CSS
  let css_files = deduplicate(filter(assets, is_css))
  if css_files.len > 0:
    let css_text = css_files.mapIt(readFile(it))
    writeFile(dir & "/" & prefix & ".css", foldr(css_text, a & b))
  # process Javascript
  var js_files = deduplicate(filter(assets, is_js))

  let coffee_files = deduplicate(filter(assets, is_coffee))
  # compile coffeescript
  for coffee_file in coffee_files:
    echo "\tcompiling: " & $coffee_file
    discard execCmd("coffee -b -c " & $coffee_file)
    let (dir, name, ext) = splitFile($coffee_file)
    js_files.add(dir & "/" & name & ".js")

  if js_files.len > 0:
    let js_text = js_files.mapIt(readFile(it))
    writeFile(dir & "/" & prefix & ".js", foldr(js_text, a & b))

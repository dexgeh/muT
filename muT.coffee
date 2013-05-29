# utility section: html escaping

html_entities =
  '<' : '&lt;'
  '>' : '&gt;'
  '&' : '&amp;'
  '"' : '&quot;'
  "'" : '&#x27;'
  '/' : '&#x2F;'

html_escaper = (c) -> html_entities[c]

html_escape = (s) -> s.replace /[<>&'"\/]/g, html_escaper

# utility section: javascript escaping

js_escapeSequences =
  "'"      : "\\'"
  '\\'     : '\\\\'
  '\r'     : '\\r'
  '\n'     : '\\n'
  '\t'     : '\\t'
  '\u2028' : '\\u2028'
  '\u2029' : '\\u2029'

js_escaper = (c) -> js_escapeSequences[c]

js_escape = (s) -> s.replace /\\|'|\r|\n|\t|\u2028|\u2029/g, js_escaper

# javascript code generator: the core of the library
# handlers : array of objects with two properties: regex and handler
#   regex is the matcher regex, it need to have at most one capturing group
#   handler is the callback triggered when a match of the given regex occurs.
#   handler arguments are the source generated before and the matched string
#   of the capturing group.
# see the defaultHandlers array for examples
toSource = (tmplSource, handlers=defaultHandlers) ->
  # 1. prepare the matcher RegExp (no map/join for backward compat)
  matcher_s = ''
  for handler in handlers
    matcher_s += handler.regex.source + '|'
  matcher_s += '$'
  matcher = new RegExp matcher_s, 'g'
  # 2. execute a string replace with the generated matcher
  fnSource = "var _muT_out='"
  index = 0
  tmplSource.replace matcher, () ->
    # for function callback arguments see:
    # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace?redirectlocale=en-US&redirectslug=JavaScript%2FReference%2FGlobal_Objects%2FString%2Freplace#Specifying_a_function_as_a_parameter
    match = arguments[0]
    offset = arguments[arguments.length - 2]
    fnSource += js_escape tmplSource.slice index, offset
    for argNum in [0..handlers.length-1]
      currentMatch = arguments[argNum + 1]
      if currentMatch
        fnSource = handlers[argNum].handler fnSource, currentMatch
        break
    index = offset + match.length
    return match
  fnSource += "'; return _muT_out;"
  return fnSource

defaultHandlers = [
  {
    # match the sequence {{...}}, interpret the internal as javascript code
    # the output of such code will be ignored
    # useful to inject conditional or loops
    regex : /\{\{([\s\S]+?)\}\}/
    handler : (fnSource, jsCode) -> fnSource + "'; #{jsCode} ; _muT_out+='"
  }
  {
    # match the sequence {=...}, the contained javascript code will be
    # invoked in the template function as is
    regex : /\{=([\s\S]+?)\}/
    handler : (fnSource, unescaped) -> fnSource + "' + #{unescaped} + '"
  }
  {
    # match the sequence {...}, the contained code will be invoked
    # in the template function, the output will be html-escaped
    regex : /\{([\s\S]+?)\}/
    handler : (fnSource, escaped) ->
      fnSource + "' + muT.html_escape('' + #{escaped}) + '"
  }
]

# this is the most useful function, it will invoke toSource and return
# a newly created javascript function with the generated source code
# and the supplied argument names
template = (tmplSource, argNames=[], handlers=defaultHandlers) ->
  fnSource = toSource tmplSource, handlers
  args = argNames.concat [fnSource]
  Function.apply null, args

window.muT =
  html_escape     : html_escape
  js_escape       : js_escape
  toSource        : toSource
  defaultHandlers : defaultHandlers
  template        : template


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
  "'" : "\\'"
  '\\' : '\\\\'
  '\r' : '\\r'
  '\n' : '\\n'
  '\t' : '\\t'
  '\u2028' : '\\u2028'
  '\u2029' : '\\u2029'

js_escaper = (c) -> js_escapeSequences[c]

js_escape = (s) -> s.replace /\\|'|\r|\n|\t|\u2028|\u2029/g, js_escaper

randomInt = (scale) -> Math.floor(Math.random()*scale)

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
  fnSource = ''
  index = 0
  tmplSource.replace matcher, () ->
    # for function callback arguments see:
    # https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#Specifying_a_function_as_a_parameter
    match = arguments[0]
    offset = arguments[arguments.length - 2]
    fnSource += js_escape tmplSource.slice index, offset
    for argNum in [0..handlers.length-1]
      currentMatch = arguments[argNum + 1]
      if currentMatch
        fnSource += handlers[argNum].handler currentMatch, handlers
        break
    index = offset + match.length
    return match
  return fnSource

defaultHandlers = [
  {
    # {if condition}
    #   body
    # {/}
    regex : /\{if ([\s\S]+?\}[\s\S]+)\{\/\}/
    handler : (text, handlers) ->
      rematch = text.match /([\s\S]+?)\}([\s\S]+)/
      condition = rematch[1]
      body = rematch[2]
      """';
      if (#{condition}) {
        _muT_out+='#{toSource body, handlers}';
      }
      _muT_out+='"""
  }
  {
    # {for element in elements}
    #   body
    # {/}
    regex : /\{for ([A-Za-z][A-Za-z0-9]+ in [\s\S]+?\}[\s\S]+)\{\/\}/
    handler : (text, handlers) ->
      rematch = text.match /([A-Za-z][A-Za-z0-9]+) in ([\s\S]+?)\}([\s\S]+)/
      [fullmatch, name, expression, body] = rematch
      idxName = "idx#{randomInt 10000}"
      exprHoldName = "expr#{randomInt 10000}"
      """';
      var #{exprHoldName} = #{expression};
      for (var #{idxName} in #{exprHoldName}) {
        var #{name} = #{exprHoldName}[#{idxName}];
        _muT_out+='#{toSource body, handlers}';
      }
      _muT_out+='"""
  }
  {
    # {for name, value of hashtable}
    #   body
    # {/}
    regex : /\{for ([A-Za-z][A-Za-z0-9]+,[A-Za-z][A-Za-z0-9]+ of [\s\S]+?\}[\s\S]+)\{\/\}/
    handler : (text, handlers) ->
      rematch = text.match /([A-Za-z][A-Za-z0-9]+),([A-Za-z][A-Za-z0-9]+) of ([\s\S]+?)\}([\s\S]+)/
      [fullmatch, name, value, expression, body] = rematch
      exprHoldName = "expr#{randomInt 10000}"
      """';
      var #{exprHoldName} = #{expression};
      for (var #{name} in #{exprHoldName}) {
        var #{value} = #{exprHoldName}[#{name}];
        _muT_out+='#{toSource body, handlers}';
      }
      _muT_out+='"""
  }
  {
    # {{ jsCode() }}
    regex : /\{\{([\s\S]+?)\}\}/
    handler: (jsCode) -> "'; #{jsCode} ; _muT_out+='"
  }
  {
    # {= jsCode() }
    regex : /\{=([\s\S]+?)\}/
    handler : (unescaped) -> "' + #{unescaped} + '"
  }
  {
    # {jsCode()}
    regex : /\{([\s\S]+?)\}/
    handler : (escaped) -> "' + muT.html_escape('' + #{escaped}) + '"
  }
]

# this is the most useful function, it will invoke toSource and return
# a newly created javascript function with the generated source code
# and the supplied argument names
template = (tmplSource, argNames=[], handlers=defaultHandlers) ->
  fnSource = "var _muT_out = '#{toSource tmplSource, handlers}'; return _muT_out;"
  args = argNames.concat [fnSource]
  return Function.apply null, args

muT =
  html_escape     : html_escape
  js_escape       : js_escape
  defaultHandlers : defaultHandlers
  template        : template

window.muT = muT

// Generated by CoffeeScript 1.6.2
(function() {
  var defaultHandlers, html_entities, html_escape, html_escaper, js_escape, js_escapeSequences, js_escaper, muT, randomInt, template, toSource;

  html_entities = {
    '<': '&lt;',
    '>': '&gt;',
    '&': '&amp;',
    '"': '&quot;',
    "'": '&#x27;',
    '/': '&#x2F;'
  };

  html_escaper = function(c) {
    return html_entities[c];
  };

  html_escape = function(s) {
    return s.replace(/[<>&'"\/]/g, html_escaper);
  };

  js_escapeSequences = {
    "'": "\\'",
    '\\': '\\\\',
    '\r': '\\r',
    '\n': '\\n',
    '\t': '\\t',
    '\u2028': '\\u2028',
    '\u2029': '\\u2029'
  };

  js_escaper = function(c) {
    return js_escapeSequences[c];
  };

  js_escape = function(s) {
    return s.replace(/\\|'|\r|\n|\t|\u2028|\u2029/g, js_escaper);
  };

  randomInt = function(scale) {
    return Math.floor(Math.random() * scale);
  };

  toSource = function(tmplSource, handlers) {
    var fnSource, handler, index, matcher, matcher_s, _i, _len;

    if (handlers == null) {
      handlers = defaultHandlers;
    }
    matcher_s = '';
    for (_i = 0, _len = handlers.length; _i < _len; _i++) {
      handler = handlers[_i];
      matcher_s += handler.regex.source + '|';
    }
    matcher_s += '$';
    matcher = new RegExp(matcher_s, 'g');
    fnSource = '';
    index = 0;
    tmplSource.replace(matcher, function() {
      var argNum, currentMatch, match, offset, _j, _ref;

      match = arguments[0];
      offset = arguments[arguments.length - 2];
      fnSource += js_escape(tmplSource.slice(index, offset));
      for (argNum = _j = 0, _ref = handlers.length - 1; 0 <= _ref ? _j <= _ref : _j >= _ref; argNum = 0 <= _ref ? ++_j : --_j) {
        currentMatch = arguments[argNum + 1];
        if (currentMatch) {
          fnSource += handlers[argNum].handler(currentMatch, handlers);
          break;
        }
      }
      index = offset + match.length;
      return match;
    });
    return fnSource;
  };

  defaultHandlers = [
    {
      regex: /\{if ([\s\S]+?\}[\s\S]+)\{\/\}/,
      handler: function(text, handlers) {
        var body, condition, rematch;

        rematch = text.match(/([\s\S]+?)\}([\s\S]+)/);
        condition = rematch[1];
        body = rematch[2];
        return "';\nif (" + condition + ") {\n  _muT_out+='" + (toSource(body, handlers)) + "';\n}\n_muT_out+='";
      }
    }, {
      regex: /\{for ([A-Za-z][A-Za-z0-9]+ in [\s\S]+?\}[\s\S]+)\{\/\}/,
      handler: function(text, handlers) {
        var body, exprHoldName, expression, fullmatch, idxName, name, rematch;

        rematch = text.match(/([A-Za-z][A-Za-z0-9]+) in ([\s\S]+?)\}([\s\S]+)/);
        fullmatch = rematch[0], name = rematch[1], expression = rematch[2], body = rematch[3];
        idxName = "idx" + (randomInt(10000));
        exprHoldName = "expr" + (randomInt(10000));
        return "';\nvar " + exprHoldName + " = " + expression + ";\nfor (var " + idxName + " in " + exprHoldName + ") {\n  var " + name + " = " + exprHoldName + "[" + idxName + "];\n  _muT_out+='" + (toSource(body, handlers)) + "';\n}\n_muT_out+='";
      }
    }, {
      regex: /\{for ([A-Za-z][A-Za-z0-9]+,[A-Za-z][A-Za-z0-9]+ of [\s\S]+?\}[\s\S]+)\{\/\}/,
      handler: function(text, handlers) {
        var body, exprHoldName, expression, fullmatch, name, rematch, value;

        rematch = text.match(/([A-Za-z][A-Za-z0-9]+),([A-Za-z][A-Za-z0-9]+) of ([\s\S]+?)\}([\s\S]+)/);
        fullmatch = rematch[0], name = rematch[1], value = rematch[2], expression = rematch[3], body = rematch[4];
        exprHoldName = "expr" + (randomInt(10000));
        return "';\nvar " + exprHoldName + " = " + expression + ";\nfor (var " + name + " in " + exprHoldName + ") {\n  var " + value + " = " + exprHoldName + "[" + name + "];\n  _muT_out+='" + (toSource(body, handlers)) + "';\n}\n_muT_out+='";
      }
    }, {
      regex: /\{\{([\s\S]+?)\}\}/,
      handler: function(jsCode) {
        return "'; " + jsCode + " ; _muT_out+='";
      }
    }, {
      regex: /\{=([\s\S]+?)\}/,
      handler: function(unescaped) {
        return "' + " + unescaped + " + '";
      }
    }, {
      regex: /\{([\s\S]+?)\}/,
      handler: function(escaped) {
        return "' + muT.html_escape('' + " + escaped + ") + '";
      }
    }
  ];

  template = function(tmplSource, argNames, handlers) {
    var args, fnSource;

    if (argNames == null) {
      argNames = [];
    }
    if (handlers == null) {
      handlers = defaultHandlers;
    }
    fnSource = "var _muT_out = '" + (toSource(tmplSource, handlers)) + "'; return _muT_out;";
    args = argNames.concat([fnSource]);
    return Function.apply(null, args);
  };

  muT = {
    html_escape: html_escape,
    js_escape: js_escape,
    defaultHandlers: defaultHandlers,
    template: template
  };

  window.muT = muT;

}).call(this);

muT - JavaScript Micro-Templating
=================================

```muT``` is a flexible tiny javascript templating library.

API description
---------------

```muT.html_escape(string)``` is an escaping utility for sanitizing the output
of the library.

```muT.js_escape(string)``` escape a string in a javascript string content.

```muT.toSource(templateString, handlers=defaultHandlers)``` it's the code
generator of muT. It will take two arguments as input:

* ```tmplSource``` is the string of source code to be transformed by the rules
* ```handlers``` is an array of objects with two properties: ```regex``` (the
  matcher regex, it is required to have at most one capturing group) and
  ```handler``` (the function callback called when a match occurs).
  ```handlers``` is an optional argument; if not supplied the
  ```defaultHandlers``` array will be used instead.

```muT.defaultHandlers``` is an array of handlers, as described before. It
includes three handlers:

* {{...}} for javascript code; the output of the invoked code will be discarded
* {=...} for javascript code; the output will be returned as is
* {...} for javascript code; the output will be html-escaped

```muT.template(templateString, argumentNames=[], handlers=defaultHandlers)```
is the most useful function, combine the ```toSource``` function and return the
compiled function with the given argument names.

Examples
--------

```
var template = muT.template("Hello { name }, it's {= date }!");
var output = template("John", "<b>" + new Date() + "</b>")
// output: Hello John, it's <b>Wed May 29 2013 21:07:56 GMT+0200 (CEST)</b>!
```

```
var templateString = "Let's count to { number }!<br>" +
  " {{ for (i = 0 ; i < number; i++) { }} " +
  "   { i }" +
  " {{ } }}!";
var template = muT.template(templateString);
var output = template(5);
// output: Let's count to 5!<br>   1   2   3   4   5!
````

```
var handlers = defaultHandlers.concat({
  regex : /(abc)/,
  handler : function(fnSource, abc) {
    return fnSource + "--> found! ' + " + abc + " + '";
  }
});
var templateString = "...123...abc...";
var template = muT.template(templateString, handlers);
var output = template();
// output: ...123...---> found! abc
```


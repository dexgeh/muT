muT - JavaScript Micro-Templating
=================================

```muT``` is a flexible tiny javascript templating library licensed under LGPL.

API description
---------------

```muT.html_escape(string)``` is an escaping utility for sanitizing the output
of the library.

```muT.js_escape(string)``` escape a string in a javascript string content.

```muT.defaultHandlers``` is an array of handlers, as described before. It
includes six handlers:

* {{...}} for javascript code; the output of the invoked code will be discarded
* {=...} for javascript code; the output will be returned as is
* {...} for javascript code; the output will be html-escaped
* {for elem in elements}...{/}: iterate through the elements array
* {for key,value of elements}...{/}: iterate through an associative array
* {if condition}...{/}: execute the inner template if condition is true

```muT.template(templateString, argumentNames=[], handlers=defaultHandlers)```
is the most useful function, return the compiled function with the given
argument names.


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
  handler : function(abc, handlers) {
    return "--> found! ' + " + abc + " + '";
  }
});
var templateString = "...123...abc...";
var template = muT.template(templateString, handlers);
var output = template();
// output: ...123...---> found! abc
```

License
-------
```
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```
![LGPL](https://www.gnu.org/graphics/lgplv3-147x51.png)

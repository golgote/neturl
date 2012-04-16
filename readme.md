## A Robust URL Parser and Builder

This small Lua library provides a few functions to parse URL with querystring and build new URL easily.

    > url = require'neturl'

### Querystring parser

The library supports brackets in querystrings, like PHP, that means you can use brackets to build multi-dimensional tables.

    > s = "first=abc&a[]=123&a[]=false&b[]=str&c[]=3.5&a[]=last"
    > q = url.parseQuery(s)
    > = q
    {first = "abc", a = {"123", "false", "last"}, b = {"str"}, c = {"3.5"}}

### URL parser

The library converts an URL to a table of the elements as described in RFC : scheme, domain, path, etc.

    > u = url.parse("http://www.example.com/?start=10")

### URL normalization

    > = url.parse("http://www.FOO.com:80///foo/../foo/./bar"):normalize()

### URL resolver

    > u = url.parse("http://a/b/c/d;p?q")
    > = u:resolve("../../g")
    "http://a/g"

### Querystring builder

    > u = url.parse("http://www.example.com")
    > u.query.net = "url"
    "http://www.example.com/?net=url"


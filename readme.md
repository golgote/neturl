## A Robust URL Parser and Builder for Lua

This small Lua library provides a few functions to parse URL with querystring and build new URL easily.

    > url = require'neturl'

### Querystring parser

The library supports brackets in querystrings, like PHP. It means you can use brackets to build multi-dimensional tables. The parsed querystring has a tostring() helper. As usual with Lua, if no index is specified, it starts from index 1.

    > query = url.parseQuery("first=abc&a[]=123&a[]=false&b[]=str&c[]=3.5&a[]=last")
    > = query
    a[1]=123&a[2]=false&a[3]=last&b[1]=str&c[1]=3.5&first=abc
    > = query.a[1]
    123

### URL parser

The library converts an URL to a table of the elements as described in RFC : scheme, host, path, etc.

    > u = url.parse("http://www.example.com/test/?start=10")
    > = u.scheme
    http
    > = u.host
    www.example.com
    > = u.path
    /test/

### URL normalization

    > = url.parse("http://www.FOO.com:80///foo/../foo/./bar"):normalize()
    http://www.foo.com/foo/bar

### URL resolver

URL resolution follows the examples provided in the [RFC 2396](http://tools.ietf.org/html/rfc2396#appendix-C).

    > = url.parse("http://a/b/c/d;p?q"):resolve("../../g")
    http://a/g

### Querystring builder

    > u = url.parse("http://www.example.com")
    > u.query.foo = "bar"
    > = u
    http://www.example.com/?foo=bar


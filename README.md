## A Robust URL Parser and Builder for Lua

This small Lua library provides a few functions to parse URL with querystring and build new URL easily.

```lua
url = require "net.url"
```

### URL parser

The library converts an URL to a table of the elements as described in RFC : scheme, host, path, etc.

```lua
u = url.parse("http://www.example.com/test/?start=10")
print(u.scheme)
-- http
print(u.host)
-- www.example.com
print(u.path)
-- /test/
```

### URL normalization

```lua
u = url.parse("http://www.FOO.com:80///foo/../foo/./bar"):normalize()
print(u)
-- http://www.foo.com/foo/bar
```

### URL resolver

URL resolution follows the examples provided in the [RFC 2396](http://tools.ietf.org/html/rfc2396#appendix-C).

```lua
u = url.parse("http://a/b/c/d;p?q"):resolve("../../g")
print(u)
-- http://a/g
```

### Path builder

Path segments can be added using the `__div` metatable or `u.addSegment()`.

```lua
u = url.parse('http://example.com')
u / 'bands' / 'AC/DC'
print(u)
-- http://example.com/bands/AC%2FDC
```

### Module Options

- `separator` is used to specify which separator is used between query parameters. It is `&` by default.
- `cumulative_parameters` is false by default. If true, query parameters with the same name will be stored in a table.
- `legal_in_path` is a table of characters that will not be url encoded in path components.
- `legal_in_query` is a table of characters that will not be url encoded in query values. Query parameters on the other hand only support a small set of legal characters (`-_.`).
- `query_plus_is_space` is true by default, so a plus sign in a query value will be converted to %20 (space), not %2B (plus).

If one wants to have the `+` sign as is in path segments, one can add it to the list of
legal characters in path. For example:

```lua
url = require "net.url"
url.options.legal_in_path["+"] = true;
```

### Querystring parser

The library supports brackets in querystrings, like PHP. It means you can use brackets to build multi-dimensional tables. The parsed querystring has a tostring() helper. As usual with Lua, if no index is specified, it starts from index 1.

```lua
query = url.parseQuery("first=abc&a[]=123&a[]=false&b[]=str&c[]=3.5&a[]=last")
print(query)
-- a[1]=123&a[2]=false&a[3]=last&b[1]=str&c[1]=3.5&first=abc
print(query.a[1])
-- 123
```

### Querystring builder

```lua
u = url.parse("http://www.example.com")
u.query.foo = "bar"
print(u)
-- http://www.example.com/?foo=bar

u:setQuery{ json = true, skip = 100 }
print(u)
-- http://www.example.com/?json=true&skip=100
```

### Differences with luasocket/url.lua

- Luasocket/url.lua can't parse http://www.example.com?url=net correctly because there are no path.
- Luasocket/url.lua can't clean and normalize url, for example by removing default port, extra zero in port, empty authority, uppercase scheme, domain name.
- Luasocket/url.lua doesn't parse the query string parameters.
- Luasocket/url.lua is less compliant with RFC 2396 and will resolve `http://a/b/c/d;p?q` and :
    `../../../g` to `http://ag` instead of `http://a/g`
    `../../../../g` to `http://a../g` instead of `http://a/g`
    `g;x=1/../y` to `http://a/b/c/g;x=1/../y` instead of `http://a/b/c/y`
    `/./g` to `http://a/./g` instead of `http://a/g`
    `g;x=1/./y` to `http://a/b/c/g;x=1/./y` instead of `http://a/b/c/g;x=1/y`


#!/usr/bin/env lua
require 'Test.More'

local url = require'neturl'
d = require'dumper'
dump = function(str, var) print(d.dump(str, var)) end

local s
local q

plan(14)

local u = url.parse("http://www.example.com")
u.query.net = "url"
is("http://www.example.com/?net=url", tostring(u), "Test new query variable")

u.query.net = "url 2nd try"
is("net=url+2nd+try", tostring(u.query), "Test build query")
is("http://www.example.com/?net=url+2nd+try", tostring(u), "Test new query variable 2")

u = url.parse("http://www.example.com/?last=mansion&first=bertrand&test=more")
is("http://www.example.com/?first=bertrand&last=mansion&test=more", tostring(u), "Test sorted query")
u.query.test = nil
is("http://www.example.com/?first=bertrand&last=mansion", tostring(u), "Test remove query parameter 1")
u.query.first = nil
is("http://www.example.com/?last=mansion", tostring(u), "Test remove query parameter 2")
u.query.last = nil
is("http://www.example.com/", tostring(u), "Test remove query parameter 3")

u = url.parse("http://www.example.com/")
u:setQuery("dilly%20all.day&flapdoodle")
is("http://www.example.com/?dilly_all.day&flapdoodle", tostring(u), "Test space in query parameters")

u.query = u.parseQuery("start=10&test[0][first][1.1][20]=coucou")
is("http://www.example.com/?start=10&test[0][first][1.1][20]=coucou", tostring(u), "Test query with brackets")
ok("10" == u.query.start, "Test query values with brackets")
ok("coucou" == u.query.test[0]["first"]["1.1"][20], "Test query values with brackets")


u = url.parse("http://example.com/")
is("http", u.scheme, "Test scheme http")
u.scheme = "gopher"
is("gopher://example.com/", tostring(u), "Test scheme gopher")

u.fragment = "lua"
is("gopher://example.com/#lua", tostring(u), "Test fragment")


local test1 = {
	["g:h"] = "g:h",
	["g"] = "http://a/b/c/g",
	["./g"] = "http://a/b/c/g",
	["g/"] = "http://a/b/c/g/",
	["/g"] = "http://a/g",
	["//g"] = "http://g",
	["?y"] = "http://a/b/c/d;p?y",
	["g?y"] = "http://a/b/c/g?y",
	["#s"] = "http://a/b/c/d;p?q#s",
	["g#s"] = "http://a/b/c/g#s",
	["g?y#s"] = "http://a/b/c/g?y#s",
	[";x"] = "http://a/b/c/;x",
	["g;x"] = "http://a/b/c/g;x",
	["g;x?y#s"] = "http://a/b/c/g;x?y#s",
	[""] = "http://a/b/c/d;p?q",
	["."] = "http://a/b/c/",
	["./"] = "http://a/b/c/",
	[".."] = "http://a/b/",
	["../"] = "http://a/b/",
	["../g"] = "http://a/b/g",
	["../.."] = "http://a/",
	["../../"] = "http://a/",
	["../../g"] = "http://a/g",
	["../../../g"] = "http://a/g",
	["../../../../g"] = "http://a/g",
	["/./g"] = "http://a/g",
	["/../g"] = "http://a/g",
	["g."] = "http://a/b/c/g.",
	[".g"] = "http://a/b/c/.g",
	["g.."] = "http://a/b/c/g..",
	["..g"] = "http://a/b/c/..g",
	["./../g"] = "http://a/b/g",
	["./g/."] = "http://a/b/c/g/",
	["g/./h"] = "http://a/b/c/g/h",
	["g/../h"] = "http://a/b/c/h",
	["g;x=1/./y"] = "http://a/b/c/g;x=1/y",
	["g;x=1/../y"] = "http://a/b/c/y",
	["g?y/./x"] = "http://a/b/c/g?y%2F.%2Fx",
	["g?y/../x"] = "http://a/b/c/g?y%2F..%2Fx",
	["g#s/./x"] = "http://a/b/c/g#s/./x",
	["g#s/../x"] = "http://a/b/c/g#s/../x",
}

for k,v in pairs(test1) do
  local u = url.parse('http://a/b/c/d;p?q')
  local res = u:resolve(k)
  is(tostring(res), v, "Test resolve '".. k.."' => '"..v..' => '..tostring(res))
end

local test2 = {
	["/foo/bar/."] = "/foo/bar/",
["/foo/bar/./"] = "/foo/bar/",
["/foo/bar/.."] = "/foo/",
["/foo/bar/../"] = "/foo/",
["/foo/bar/../baz"] = "/foo/baz",
["/foo/bar/../.."] = "/",
["/foo/bar/../../"] = "/",
["/foo/bar/../../baz"] = "/baz",
["/./foo"] = "/foo",
["/foo."] = "/foo.",
["/.foo"] = "/.foo",
["/foo.."] = "/foo..",
["/..foo"] = "/..foo",
["/./foo/."] = "/foo/",
["/foo/./bar"] = "/foo/bar",
["/foo/../bar"] = "/bar",
["/foo//"] = "/foo/",
["/foo///bar//"] = "/foo/bar/",
["http://www.foo.com:80/foo"] = "http://www.foo.com/foo",
["http://www.foo.com/foo/../foo"] = "http://www.foo.com/foo",
["http://www.foo.com:8000/foo"] = "http://www.foo.com:8000/foo",
["http://www.foo.com/%7ebar"] = "http://www.foo.com/~bar",
["http://www.foo.com/%7Ebar"] = "http://www.foo.com/~bar",
 -- not sure which result I should get here
 --["http://www.foo.com/?p=529&#038;cpage=1#comment-783"] = "http://www.foo.com/?p=529&",
 --["http://www.foo.com/?p=529&#038;cpage=1#comment-783"] = "http://www.foo.com/?p=529&#038;cpage=1#comment-783",
["/foo/bar/../../../baz"] = "/baz",
["/foo/bar/../../../../baz"] = "/baz",
["/./../foo"] = "/foo",
["/../foo"] = "/foo",
}

for k,v in pairs(test2) do
  local u = url.parse(k):normalize()
  is(tostring(u), v, "Test normalize '".. k .."' => '".. v .."' => '"..tostring(u).."'")
end











local test2 = {
	["http://:@example.com/"] = "http://example.com/",
	["http://@example.com/"] = "http://example.com/",
	["http://example.com"] = "http://example.com",
	["HTTP://example.com/"] = "http://example.com/",
	["http://EXAMPLE.COM/"] = "http://example.com/",
	["http://example.com/%7Ejane"] = "http://example.com/~jane",
	["http://example.com/?q=%C3%87"] = "http://example.com/?q=%C3%87",
	["http://example.com/?q=%E2%85%A0"] = "http://example.com/?q=%E2%85%A0",
	["http://example.com/?q=%5c"] = "http://example.com/?q=%5C",
	["http://example.com/?q=%5C"] = "http://example.com/?q=%5C",
	["http://example.com/a/../a/b"] = "http://example.com/a/b",
	["http://example.com/a/./b"] = "http://example.com/a/b",
	["http://example.com:80/"] = "http://example.com/",
	["http://example.com/"] = "http://example.com/",
	["http://example.com/~jane"] = "http://example.com/~jane",
	["http://example.com/a/b"] = "http://example.com/a/b",
	["http://example.com:8080/"] = "http://example.com:8080/",
	["http://user:password@example.com/"] = "http://user:password@example.com/",
	["http://www.ietf.org/rfc/rfc2396.txt"] = "http://www.ietf.org/rfc/rfc2396.txt",
	["telnet://192.0.2.16:80/"] = "telnet://192.0.2.16:80/",
	["ftp://ftp.is.co.za/rfc/rfc1808.txt"] = "ftp://ftp.is.co.za/rfc/rfc1808.txt",
	["ldap://[2001:db8::7]/c=GB?objectClass?one"] = "ldap://[2001:db8::7]/c=GB?objectClass?one",
	["mailto:John.Doe@example.com"] = "mailto:John.Doe@example.com",
	["news:comp.infosystems.www.servers.unix"] = "news:comp.infosystems.www.servers.unix",
	["urn:oasis:names:specification:docbook:dtd:xml:4.1.2"] = "urn:oasis:names:specification:docbook:dtd:xml:4.1.2",
	["http://www.w3.org/2000/01/rdf-schema#"] = "http://www.w3.org/2000/01/rdf-schema#",
	["http://127.0.0.1/"] = "http://127.0.0.1/",
	["http://127.0.0.1:80/"] = "http://127.0.0.1/",
	["http://example.com:081/"] = "http://example.com:81/",
	["http://example.com/?q=foo"] = "http://example.com/?q=foo",
	["http://example.com?q=foo"] = "http://example.com/?q=foo",
}

for k,v in pairs(test2) do
  local u = url.parse(k)
  is(tostring(u), v, "Test normalize '".. k.."' => '"..v..' => '..tostring(u))
end


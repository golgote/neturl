#!/usr/bin/env lua
require 'Test.More'

local url = require 'net.url'

local s
local q

plan(29)

s = "first=abc&a[]=123&a[]=false&b[]=str&c[]=3.5&a[]=last"
q = url.parseQuery(s)
is_deeply(q, {
  first = "abc",
  a = {
    "123", "false", "last"
  },
  b = {"str"},
  c = {"3.5"}
}, "Test string with array values")


s = "first&second=&a[]=&a[]&a[4]=&b[1][1]"
q = url.parseQuery(s)
is_deeply({
  first = "",
  second = "",
  a = {
    "", "", [4] = ""
  },
  b = {{""}}
}, q, "Test with empty string")
is(tostring(q), 'a[1]&a[2]&a[4]&b[1][1]&first&second', "Build query with empty string")


s = "arr[0]=sid&arr[4]=bill"
q = url.parseQuery(s)
is_deeply(q, {arr = {[0] = "sid", [4] = "bill"}}, "Test string containing numerical array keys")


s = "arr[first]=sid&arr[last]=bill"
q = url.parseQuery(s)
is_deeply(q, {arr = {first = "sid", last = "bill"}}, "Test string containing associative keys")


s = "a=%3c%3d%3d%20%20foo+bar++%3d%3d%3e&b=%23%23%23Hello+World%23%23%23"
q = url.parseQuery(s)
is_deeply(q, {
   ["a"] = "<==  foo bar  ==>";
   ["b"] = "###Hello World###";
}, "Test string with encoded data and plus signs")


s = "firstname=Bill&surname=O%27Reilly"
q = url.parseQuery(s)
is_deeply(q, {
   ["firstname"] = "Bill",
   ["surname"] = "O'Reilly"
}, "Test string with single quotes characters")


s = "sum=10%5c2%3d5"
q = url.parseQuery(s)
is_deeply(q, {
   ["sum"] = "10\\2=5"
}, "Test string with backslash characters")


s = "str=A%20string%20with%20%22quoted%22%20strings"
q = url.parseQuery(s)
is_deeply(q, {
   ["str"] = "A string with \"quoted\" strings"
}, "Test string with double quotes data")


s = "str=A%20string%20with%20%00%00%00%20nulls"
q = url.parseQuery(s)
is_deeply(q, {
   ["str"] = "A string with     nulls"
}, "Test string with nulls")


s = "arr[3][4]=sid&arr[3][6]=fred"
q = url.parseQuery(s)
is_deeply(q, {
   ["arr"] = {
     [3] = {
       [4] = "sid",
       [6] = "fred"
     }
   }
}, "Test string with 2-dim array with numeric keys")


s = "arr[][]=sid&arr[][]=fred"
q = url.parseQuery(s)
is_deeply(q, {
   ["arr"] = {
     [1] = {[1] = "sid"},
     [2] = {[1] = "fred"}
   }
}, "Test string with 2-dim array with null keys")


s = "arr[one][four]=sid&arr[three][six]=fred"
q = url.parseQuery(s)
is_deeply(q, {
   ["arr"] = {
     ["one"] = {["four"] = "sid"},
     ["three"] = {["six"] = "fred"}
   }
}, "Test string with 2-dim array with non-numeric keys")


s = "arr[1][2][3]=sid&arr[1][2][6]=fred"
q = url.parseQuery(s)
is_deeply(q, {
   ["arr"] = {
     [1] = {
       [2] = {
         [3] = "sid",
         [6] = "fred",
       }
      }
   }
}, "Test string with 3-dim array with numeric keys")
is(tostring(q), 'arr[1][2][3]=sid&arr[1][2][6]=fred', "Build query with multi dimensions parameters")

s = "arr[1=sid&arr[4][2=fred&arr[4][3]=test&arr][4]=abc&arr]1=tata&arr[4]2]=titi"
q = url.parseQuery(s)
is_deeply(q, {
   ["arr[1"] = 'sid',
   ["arr"] = {[4] = 'titi'},
   ["arr]"] = {[4] = 'abc'},
   ["arr]1"] = 'tata'
}, "Test string with badly formed strings")


s = "arr1]=sid&arr[4]2]=fred"
q = url.parseQuery(s)
is_deeply(q, {
   ["arr1]"] = "sid",
   ["arr"] = {[4] = "fred"}
}, "Test string with badly formed strings")
is(tostring(q), 'arr[4]=fred&arr1%5D=sid', "Build query with badly formed strings")

s = "arr[one=sid&arr[4][two=fred"
q = url.parseQuery(s)
is_deeply(q, {
   ["arr[one"] = "sid",
   ["arr"] = {[4] = "fred"}
}, "Test string with badly formed strings")
is(tostring(q), 'arr[4]=fred&arr%5Bone=sid', "Build query with badly formed strings")

s = "first=%41&second=%a&third=%b"
q = url.parseQuery(s)
is_deeply(q, {
   ["first"] = "A",
   ["second"] = "%a",
   ["third"] = "%b"
}, "Test string with badly formed % numbers")


s = "arr.test[1]=sid&arr test[4][two]=fred"
q = url.parseQuery(s)
is_deeply(q, {
  ["arr.test"] = {[1] = "sid"},
  ["arr_test"] = {
     [4] = {["two"] = "fred"}
   }
}, "Test string with non-binary safe name")


url.options.separator = ";"
s = ";first=val1;;;;second=val2;third[1]=val3;";
q = url.parseQuery(s)
is_deeply(q, {
   ["first"] = "val1",
   ["second"] = "val2",
   ["third"] = {[1] = "val3"},
}, "Non default separator")
is(tostring(q), 'first=val1;second=val2;third[1]=val3', "Build query with non default separator")

url.options.separator = "&"
url.options.cumulative_parameters = true
s = "param=val1&param=val2";
q = url.parseQuery(s)
is_deeply(q, {
   ["param"] = {[1] = "val1", [2] = "val2"}
}, "Same name parameters create a table")
is(tostring(q), s, "Build query with cumulative_parameters")

url.options.cumulative_parameters = true
s = "param=val1&param=val2&param[test]=val3";
q = url.parseQuery(s)
is_deeply(q, {
   ["param"] = {[1] = "val1", [2] = "val2", ['test'] = "val3"}
}, "Mix brackets and cumulative parameters")
is(tostring(q), s, "Build query with cumulative_parameters and brackets")


-- Ticket #28
url.options.separator = "&"
s = "a=b\"c=d"
q = url.parseQuery(s)
is_deeply(q, {
  a = "b\"c=d",
}, "Test quote and two equal signs in parameters")

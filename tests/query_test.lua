#!/usr/bin/env lua
require 'Test.More'

-- раскомментировать для отладки
require('mobdebug').start('127.0.0.1')

local url = require'neturl'
d = require'dumper'
dump = function(str, var) print(d.dump(str, var)) end

local s
local q

plan(22)

s = "first=abc&a[]=123&a[]=false&b[]=str&c[]=3.5&a[]=last"
q = url.parseQuery(s)
is_deeply({
  first = "abc",
  a = {
    "123", "false", "last"
  },
  b = {"str"},
  c = {"3.5"}
}, q, "Test string with array values")


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


s = "arr[0]=sid&arr[4]=bill"
q = url.parseQuery(s)
is_deeply({arr = {[0] = "sid", [4] = "bill"}}, q, "Test string containing numerical array keys")


s = "arr[first]=sid&arr[last]=bill"
q = url.parseQuery(s)
is_deeply({arr = {first = "sid", last = "bill"}}, q, "Test string containing associative keys")


s = "a=%3c%3d%3d%20%20foo+bar++%3d%3d%3e&b=%23%23%23Hello+World%23%23%23"
q = url.parseQuery(s)
is_deeply({
   ["a"] = "<==  foo bar  ==>";
   ["b"] = "###Hello World###";
}, q, "Test string with encoded data and plus signs")


s = "firstname=Bill&surname=O%27Reilly"
q = url.parseQuery(s)
is_deeply({
   ["firstname"] = "Bill",
   ["surname"] = "O'Reilly"
}, q, "Test string with single quotes characters")


s = "sum=10%5c2%3d5"
q = url.parseQuery(s)
is_deeply({
   ["sum"] = "10\\2=5"
}, q, "Test string with backslash characters")


s = "str=A%20string%20with%20%22quoted%22%20strings"
q = url.parseQuery(s)
is_deeply({
   ["str"] = "A string with \"quoted\" strings"
}, q, "Test string with double quotes data")


s = "str=A%20string%20with%20%00%00%00%20nulls"
q = url.parseQuery(s)
is_deeply({
  -- null symbols break ZeroBraneStudio
   ["str"] = "A string with " .. string.char(0):rep(3) .. " nulls"
}, q, "Test string with nulls")


s = "arr[3][4]=sid&arr[3][6]=fred"
q = url.parseQuery(s)
is_deeply({
   ["arr"] = {
     [3] = {
       [4] = "sid",
       [6] = "fred"
     }
   }
}, q, "Test string with 2-dim array with numeric keys")


s = "arr[][]=sid&arr[][]=fred"
q = url.parseQuery(s)
is_deeply({
   ["arr"] = {
     [1] = {[1] = "sid"},
     [2] = {[1] = "fred"}
   }
}, q, "Test string with 2-dim array with null keys")


s = "arr[one][four]=sid&arr[three][six]=fred"
q = url.parseQuery(s)
is_deeply({
   ["arr"] = {
     ["one"] = {["four"] = "sid"},
     ["three"] = {["six"] = "fred"}
   }
}, q, "Test string with 2-dim array with non-numeric keys")


s = "arr[1][2][3]=sid&arr[1][2][6]=fred"
q = url.parseQuery(s)
is_deeply({
   ["arr"] = {
     [1] = {
       [2] = {
         [3] = "sid",
         [6] = "fred",
       }
      }
   }
}, q, "Test string with 3-dim array with numeric keys")


s = "arr[1=sid&arr[4][2=fred&arr[4][3]=test&arr][4]=abc&arr]1=tata&arr[4]2]=titi"
q = url.parseQuery(s)
is_deeply({
   ["arr[1"] = 'sid',
   ["arr"] = {[4] = 'titi'},
   ["arr]"] = {[4] = 'abc'},
   ["arr]1"] = 'tata'
}, q, "Test string with badly formed strings")


s = "arr1]=sid&arr[4]2]=fred"
q = url.parseQuery(s)
is_deeply({
   ["arr1]"] = "sid",
   ["arr"] = {[4] = "fred"}
}, q, "Test string with badly formed strings")


s = "arr[one=sid&arr[4][two=fred"
q = url.parseQuery(s)
is_deeply({
   ["arr[one"] = "sid",
   ["arr"] = {[4] = "fred"}
}, q, "Test string with badly formed strings")


s = "first=%41&second=%a&third=%b"
q = url.parseQuery(s)
is_deeply({
   ["first"] = "A",
   ["second"] = "%a",
   ["third"] = "%b"
}, q, "Test string with badly formed % numbers")


s = "arr.test[1]=sid&arr test[4][two]=fred"
q = url.parseQuery(s)
is_deeply({
  ["arr.test"] = {[1] = "sid"},
  ["arr_test"] = {
     [4] = {["two"] = "fred"}
   }
}, q, "Test string with non-binary safe name")

url.allow_args_names_repetition = true
s = "arg1=z&arg1=t&arg2=p"
q = url.parseQuery(s)
is_deeply({
  arg1 = 'z|t',
  arg2 = 'p',
}, q, "Test string with allowed arguments names repetition")
is('arg1=z&arg1=t&arg2=p',
    url.buildQuery(q), 'Test build back with allowed arguments names repetition'
)

url.allow_args_names_repetition = false
s = "arg1=z&arg1=t&arg2=p"
q = url.parseQuery(s)
is_deeply({
  arg1 = 'z',
  arg2 = 'p',
}, q, "Test string with disallowed arguments names repetition")


url.options.separator = ";"
s = ";first=val1;;;;second=val2;third[1]=val3;";
q = url.parseQuery(s)
is_deeply({
   ["first"] = "val1",
   ["second"] = "val2",
   ["third"] = {[1] = "val3"},
}, q, "Non default separator")


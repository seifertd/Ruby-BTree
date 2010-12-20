btree
===========

Pure ruby implementation of a btree as described in Introduction to Algorithms by 
Cormen, Leiserson, Rivest and Stein, Chapter 18.

Features
--------

* Create B-Tree of arbitrary degree (2 by default)
* Insert key value pairs using a Map like interface
* Query for values associated with keys using a Map like interface
* Keys can be any object supporting comparison operators: <, > and ==

Examples
--------

require 'btree'
tree = Btree.create    # default degree = 2
tree = Btree.create(5) # degree = 5
tree['foo'] = 'foo value'
tree['bar'] = 'bar value'

puts "key 'foo' has value: #{tree['foo']}"

Future
------------

* Deletion is not implemented. TODO: Implement deletion
* Attempt to insert existing key raises RuntimeError.
  TODO: Allow replacement of value associated with existing key instead of raising RuntimeError.
* Persist state to backing store

Install
-------

* gem install btree

Author
------

Original author: Douglas A. Seifert (doug@dseifert.net)

License
-------

(The MIT License)

Copyright (c) 2010,2011 Douglas A. Seifert

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

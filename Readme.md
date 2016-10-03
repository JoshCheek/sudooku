Sudoku Solver
=============

Uhm, not-really-working (or else just too slow). But I don't really want to spend more time on it,
I was ADDing by starting it -.-

[This](http://www.sudokuwiki.org) site has some wonderful approaches to solving Sudoku for humans,
I really like the colouring ones.

[This](https://www.safaribooksonline.com/library/view/the-ruby-programming/9780596516178/ch01s04.html)
one is able to solve the ones mine gets blocked out on. It's from
[The Ruby Programming Language](https://www.amazon.com/Ruby-Programming-Language-David-Flanagan/dp/0596516177/ref=sr_1_1?ie=UTF8&qid=1475526714&sr=8-1&keywords=the+ruby+programming+language).
I looked through it, seems the difference is probably in the `scan` method,
they probably cut off large trees of possibilities whereas I go down them.
Probably also useful to use an internal representation of a string instead of
arrays of strings (better memory use and might be able to take advantage of CPU caching).


License
-------

<a href="http://www.wtfpl.net/"><img src="http://www.wtfpl.net/wp-content/uploads/2012/12/wtfpl.svg" height="20" alt="WTFPL" /></a>
Do what the fuck you want to.

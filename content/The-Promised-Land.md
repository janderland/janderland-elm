# The Promised Land

2018-10-15 22:26:00

- code
- word

---

I've been building this form of expression for a couple
years now, and what better form then self expression, so
this site's first words will be autobiographical.

Welcome to the _Land of Jander_, a testament to how I spend
my time. Besides providing me with a place for self
expression, __jander.land__ is my first Elm application, my
second code-generation pipeline, and a project that took way
more of my time then it should've.

![Old Site](/oldsite.jpg)

The site's birth was during March of 2016. Originally, it
was built upon the Hexo Blog Framework combined with some
Sass and JavaScript I wrote. This setup ultimately became to
unwieldy for my liking, but it did lead me on some
interesting journies. While attempting to paginate and
search over a list of data entries.

This JavaScript spawned the creation of one of my major
projects. At this point I hadn't discovered functional
programming, and while implementing a pagination feature,
I realized the utility of a list of functions being applied
to a stream of data, the result of each function piped into
the next. I wrote a lot of imperative code to enable simple
function composition. This was my gateway to a new way of
thinking.

Since then it has been completely rewritten with a focus on
content rather than features. I emerged from my rabbit hole
with the motto of "simple but original". I didn't want
factory default, I wanted something unique from the ground
up, and yet something actual instead of a longer bucket
list.

> I'm in love with functional programming. I want a honeymoon.

Well, I guess I'll go with Elm.

> I want the content to be sharable in a compact format.

Ok, we can write it in markdown.

> I also don't want any runtime errors. I'm using Elm after all.

Fine, using Node.js, we'll transpile the markdown into Elm
with the Elm compiler double checking our work.


# WEBAPP: github.com/janderland/janderland-elm

The Design of JANDER.LAND
- Big Picture
- What's generated?
- Folder structure & scripts
- SPA state machine
- Elm-UI
- Scaling

```
let code = eval("var code =");
```


# CONTENT: content/The-Promised-Land.md

Extending the Markdown Syntax


# GENERATE: scripts/generate.js

The Generation Pipeline
1. Split the content files into branches
2. Design code paths for every branch
3. Fail quick
4. Pipes are the main abstraction

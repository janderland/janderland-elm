# Versioning

Q: How do we support multiple versions of an article?


## A1: Multiple files.

Grouped together via a common prefix.

Pro:
- Simple

Con:
- It's easy to change old versions of the article. Ideally,
  older versions would be immutable.


## A2: Tag versions of the article in Git.

The generate script then gets the old version of the
article.

Pro:
- Older versions of an article are immutable.

Con:
- Can we get an older version of a file without affecting
  the working directory.
- Complicated

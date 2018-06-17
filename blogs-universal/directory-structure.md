# Directory Structure

blogs-universal/package.json is a global package dependency list used across all blogs. It is used *simultaneously* with
blog-specific package.json files.

blogs-universal/src/ is a base layer that will have blog-specific *overlays* placed/overwriting on top of it. AKA *non*-simultaneous
use.

In the future, if there are more files that require simultaneous use, like package.json, perhaps it'll be necessary to
create a clearer globals-overlay vs. globals (non-overlay) directory structure.

**NOTE**: Overlaying *only* happens in prod if deploying with docker. Which means right now, it doesn't happen at all! It's just there for reference in case I want to implement that in the future.

What actually happens now is globals and blog-specific directories get isolated in docker, and the npm tooling will
reference both as necessary to build the static site. So no overlaying behavior is actually implemented yet other than
the Dockerfile lines which isn't used in development due to those directories being bind-mounted.

# UPDATE - 2018-06-17

Removed docker-container file layering in terms of setting the base as the
initial layer and then copying blog instance specific files on top of it

I think it's just easier to directly refer to globals or local files by way of
the template: globals/template.jade rather than overlaying and not being sure
which file is being referenced.

The other goal was to make the host machine directory structure and the
container directory structure exactly the same. Instead of mutating the
container directory structure that you have to put effort into visualizing how
the changes will end up in the container.

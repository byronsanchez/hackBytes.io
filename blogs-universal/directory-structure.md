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

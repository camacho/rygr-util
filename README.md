Rygr Util
=============

Set of utilities to be used in Rygr Projects

Methods
=======

Config
------
Config allows a user to read in objects from a variety of files, merge configruations, and specify properties based on the environment. Configurations come back as a single object, with keys corresponding to the basename of the matched file, and the values a nested merge of the files contents.

### Require
```coffee
{config} = require 'rygr-util'
```

or in JavaScript
```js
config = require('rygr-util').config
```

### Arguments
Config takes two arguments:

* Glob query **Array<String>|String** *(required)*
  An array of glob query strings or single glob query. If the argument is an array, the order in which the queries are passed in will be the order in which they configs override each other when the contents of the files are merged.
* Options **Object** *(optional)*
  An object to change default behavior of the method

### Defaults

**Any of these defaults can be overriden by passing in a value to options**

* env **(process.env.NODE_ENV or 'development')**
    The current environment. This is used to pick configurations that are conditionalized by environment.
* freeze **(true)**
    Whether or not to use a deep version of Object.freeze on the final configurations
* inMemory **(true)**
    Whether to augment the config object in memory or return a new object. If `inMemory` is true, running `{config} = require rygr-util` will return the already populated configuration object in the future.
* cwd **(process.cwd())**
    The working directory to use when matching the glob queries
* root **(path.resolve options.cwd, '/')**
    The root directory to use when matching the glob queries

### Simple Usage
With the following files:

#### `config/foo.json`:
```json
{
  "name": "foo"
}
```

#### `config/bar.json`:
```json
{
  "name": "bar"
}
```

Calling the initialize method and passing in a glob query:

```coffee
{config} = require 'rygr-util'
config.initialize 'config/**.json'

console.log config
# foo:
#   name: 'foo'
# bar
#   name: 'bar'
```

### Complex Useage
It is possible to also provide overrides for files and merge from many different queries. The order in which glob strings are declared in the `queries` parameter are the order of prescendence when the values from same-name files are merged.

Add a third file, named `/srv/foo.json`:

#### `/srv/config/foo.json`
```json
{
  "name": "top foo",
  "status": "active",
  "environments": {
    "test": {
      "status": "testing"
    }
  }
}
```

Config will merge the values from the various files together, and pick specific attributes based on the environment as follows:

```coffee
{config} = require 'rygr-util'
config.initialize ['config/*.json', '/srv/config/*.json'], env: 'test'

console.log config
# foo:
#   name: 'foo'
#   status: 'testing'
# bar:
#   name: 'bar'
```

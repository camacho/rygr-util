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

Async Queue
------

```coffee
{asyncQueue} = require 'rygr-util'
```
Async queue allows you to assemble a series of asynchronous methods to be run in a sequence. This is inspired by Express' middleware feature.

### Require
```coffee
{asyncQueue} = require 'rygr-util'
```

or, in JavaScript

```js
asyncQueue = require('rygr-util').asyncQueue
```

### Arguments
Async queue takes three arguments:

* Args **Array|null** *(required)*
  An array of arguments to be passed to each method in the queue
* Queue *Array<Functions>** *(required)*
  An array of functions to be called in sequence. Each function will receive the arguments passed in and an extra `next` function to trigger the next function in the queue (required). An error function can be included and is expected to take an extra argument.
* Done **Function** *(optional)*
  A callback function to be executed when the sequence completes or is short-circuited because of an error. It will receive an error as it's first argument if one occured, or null otherwise.

### Useage
```coffee
{asyncQueue} = require 'rygr-util'

first = (name, next) ->
  console.log "#{ name }: first!"
  next()

# Throwing an error (or calling next with an error) will cause the queue to skip
# to the error function or skip to call done if none is provided
second = (name, next) ->
  throw new Error 'Uhoh!'

# This function will be skipped since second threw an error
third = (name, next) ->
  console.log "#{ name }: third!"

# The queue will know this is an error method since it takes an extra argument
errorHandler = (error, name, next) ->
  console.log error.message
  next error

# This function will be called last after all the queue has been exhausted
done = (error) ->
  console.log if error then  "Something went wrong." else "Success!"

# Call asyncQueue with the args, function queue, and done function
asyncQueue(['Test'], [
  first
  second
  third
  errorHandler
], done)

# Output:
# Test: first!
# Uhoh!
# Something went wrong.
```

fs = require 'fs'
del = require 'del'
path = require 'path'

configReqPath = path.resolve __dirname, '../../lib/config'
tmpDir1 = path.resolve __dirname, '.tmp1'
tmpDir2 = path.resolve __dirname, '.tmp2'
tmpDir3 = path.resolve __dirname, '.tmp3'

dirs = {}
dirs[tmpDir1] =
  a:
    name: 'a'
    foo: 'bar'
    bar:
      baz: 'qux'
  b:
    name: 'b'
    qux: 'foo'

dirs[tmpDir2] =
  a:
    name: 'a2'
    bar:
      qux: 'baz'
  c:
    name: 'c'

dirs[tmpDir3] =
  a:
    name: 'a3'
    bar:
      foo: 'bar'
    environments:
      development:
        bar:
          foo: 'baz'

beforeEach ->
  for dir, files of dirs
    del.sync dir
    fs.mkdirSync dir
    for name, file of files
      fs.writeFileSync "#{dir}/#{name}.json", JSON.stringify file

afterEach ->
  # del.sync dir for dir of dirs
  delete require.cache["#{configReqPath}.js"]

describe 'glob matching', ->
  it 'can read in files from glob', ->
    config = require(configReqPath).initialize "#{tmpDir1}/*.json"
    expect(config).toEqual dirs[tmpDir1]

  it 'can merge files from multiple globs', ->
    glob = ["#{tmpDir1}/*.json", "#{tmpDir2}/*.json"]
    config = require(configReqPath).initialize glob...
    expect(config).toEqual
      a:
        name: 'a2'
        foo: 'bar'
        bar:
          baz: 'qux'
          qux: 'baz'
      b:
        name: 'b'
        qux: 'foo'
      c:
        name: 'c'

  it 'can handle complex globs', ->
    glob = [
      ["#{tmpDir1}/*.json", "!#{tmpDir1}/a.json"]
      ["#{tmpDir2}/*.json", "!#{tmpDir2}/a.json"]
    ]

    config = require(configReqPath).initialize glob...
    expect(config).toEqual
      b:
        name: 'b'
        qux: 'foo'
      c:
        name: 'c'

describe 'environmental vars', ->
  it 'can merge in environmental overrides', ->
    config = require(configReqPath).initialize "#{tmpDir3}/*.json"
    expect(config).toEqual
      a:
        name: 'a3'
        bar:
          foo: 'baz'

    expect(config.environments).toBeUndefined()

describe 'merging multiple files with env overrides', ->
  it 'can merge in environmental overrides and multiple files', ->
    glob = ["#{tmpDir1}/*.json", "#{tmpDir2}/*.json", "#{tmpDir3}/*.json"]
    config = require(configReqPath).initialize glob...
    expect(config).toEqual
      a:
        name: 'a3'
        foo: 'bar'
        bar:
          foo: 'baz'
          baz: 'qux'
          qux: 'baz'
      b:
        name: 'b'
        qux: 'foo'
      c:
        name: 'c'

describe 'handling options', ->
  it 'will not include options', ->
    config = require(configReqPath).initialize "#{tmpDir1}/*.json", {foo: 'bar'}
    expect(config).toEqual dirs[tmpDir1]

  it 'can handle not storing configs in memory', ->
    config = require configReqPath
    config.initialize "#{tmpDir1}/*.json", inMemory: false
    expect(config.initialize).toBeDefined()

  it 'does not freeze attributes when told not to', ->
    config = require configReqPath
    config.initialize "#{tmpDir1}/*.json", freeze: false
    config.a.name = 'bar'
    expect(config.a.name).toEqual 'bar'

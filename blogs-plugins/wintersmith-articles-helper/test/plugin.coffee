wintersmith = require 'wintersmith'
chai = require 'chai'
expect = chai.expect

Config = require('wintersmith/src/core/config').Config
wsHandleize = require './../src'
env = wintersmith(Config, __dirname)

describe "wintersmith-handleize-helper", ->
  beforeEach (done) ->
    wsHandleize env, ->
      done()
  
  it "should return a handleized version of a string argument", (done) ->
    stringToHandleize1 = "The Wintersmith"
    stringToHandleize2 = "String /with. some punctuation';"
    stringToHandleize3 = "normal-string-that-is-already-handleized"

    handleizedString1 = env.helpers.handleize(stringToHandleize1)
    handleizedString2 = env.helpers.handleize(stringToHandleize2)
    handleizedString3 = env.helpers.handleize(stringToHandleize3)

    expect(handleizedString1).to.equal('the-wintersmith')
    expect(handleizedString2).to.equal('string-with-some-punctuation')
    expect(handleizedString3).to.equal(stringToHandleize3)

    done()


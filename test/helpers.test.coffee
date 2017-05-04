chai = require 'chai'
expect = chai.expect
helpers = require '../src/helpers'

describe 'octoHelpers', ->
  beforeEach ->
    @subject = helpers.octoHelpers
  
  context 'slugIt', ->
    testCases = [
        {
          case: 'Something Foo Service'
          expected: 'something-foo-service'
        },
        {
          case: 'This.Foo.Svc'
          expected: 'this-foo-svc'
        },
        {
          case: 'This.FOO Svc'
          expected: 'this-foo-svc'
        }
    ]
    
    testCases.forEach (testCase) ->
      it "should slug #{testCase.case} correctly", () ->
        result = @subject.slugIt(testCase.case)
        expect(result).to.equal testCase.expected
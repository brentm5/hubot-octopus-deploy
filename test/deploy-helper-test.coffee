chai = require 'chai'
expect = chai.expect

subject = require '../src/deploy-helper'

describe 'deploy-helper', ->
  context 'getProjectId', ->
    before () ->
      @projectTestData =
        Id: 'value'
    it 'should return back the id of the project', () ->
      result = subject.getProjectId @projectTestData
      expect(result).to.equal 'value'

  context 'getReleaseId', ->
    before () ->
      @releaseTestData =
        Items: [
          { Id: 'Releases-1', Version: '1.0.0' },
          { Id: 'Releases-11', Version: '1.1.0' },
          { Id: 'Releases-2', Version: '2.0.0' }
        ]
    it 'should return back the id of the release', () ->
      result = subject.getReleaseId @releaseTestData, '1.1.0'
      expect(result).to.equal 'Releases-11'

  context 'getEnvironmentId', ->
    before () ->
      @environmentsTestData =
        Items: [
          { Id: 'Environments-1', Name: 'DEV' },
          { Id: 'Environments-11', Name: 'STAGE' },
          { Id: 'Environments-2', Name: 'PROD' }
        ]
    it 'should return back the id of the environment', () ->
      result = subject.getEnvironmentId @environmentsTestData, 'prod'
      expect(result).to.equal 'Environments-2'     
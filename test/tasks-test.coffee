SinonChai = require('sinon-chai')
Chai   = require('chai')
mock   = require('sinon').mock
stub   = require('sinon').stub
Chai.use(SinonChai)
expect = Chai.expect

Helper = require('hubot-test-helper')

# mock dependencies
OctopusClient = require 'octopus-deploy-client'
StatusReport = require '../src/status-report'
MatchProjects = require '../src/match-projects'
OctoHelpers = require('../src/helpers').octoHelpers
DeployHelper = require '../src/deploy-helper'

helper = new Helper('../src/scripts/tasks.coffee')

describe 'hubot-octopus-deploy', ->
  before ->
    @client =
      resources:
        dashboard:
          get: stub()
        projects:
          id: (x) -> x
          releases: (x) -> x
        environments: 
          get: (x) -> x
        deployments:
          post: (x) -> x
    @octopusClient = stub OctopusClient, 'Create', =>
      @client
    
    releaseGet = stub()
    releaseGet.returns(Promise.resolve({status: 200, body: 'release'}))
    
    idStub = stub(@client.resources.projects, 'id').returns
      get: stub().returns Promise.resolve({status: 200, body: 'projects'}) 
      releases: {get: releaseGet}
    @matchProjectsMock = stub(MatchProjects, 'find')
    
    @environmentStub = stub(@client.resources.environments, 'get')
    @environmentStub.returns Promise.resolve({status: 200, body: 'environments'})
  
  beforeEach ->
    # no http calls to be made to the hubot server
    @room = helper.createRoom(httpd: false)

  after ->
    OctopusClient.Create.restore()

  describe 'octo status', ->
    context 'search with matching regex', ->
      beforeEach (done)->
        @dashboard = Projects: [
          {Slug: 'foo',
          Id: 'foo'}
          ,
          {Slug: 'bar',
          Id: 'bar'}
          ,
          {Slug: 'fo',
          Id: 'not'}
        ]
        @client.resources.dashboard.get.returns(Promise.resolve({status: 200, body: @dashboard}))
        @extendWithLatestReleaseStub = stub(StatusReport, 'extendWithLatestRelease')
        @extendWithLatestReleaseStub.returns 'some report'
        @createMapperStub = stub(StatusReport, 'createMapper')
        @createMapperStub.returns((something) -> something)
        @matchProjectsMock.returns([
          {Slug: 'foo',
          Id: 'foo'}
          ])
        @room.user.say('alice', '@hubot octo status foo').then =>
          done()
      afterEach ->
        StatusReport.extendWithLatestRelease.restore()
        StatusReport.createMapper.restore()

      it 'should get releases for found projects', ->
        expect(@client.resources.projects.id).to.have.been.calledWith 'foo'

      it 'should create a status mapper with the dashboard', ->
        expect(@createMapperStub).to.have.been.calledWith @dashboard

      it 'should extend the information with latest release', ->
        expect(@extendWithLatestReleaseStub).to.have.been.called

  describe 'octo deploy', () ->
    before ->
      stub(OctoHelpers, 'slugIt').returns('slug')      
    
    context 'valid request', ->
      before ->
        stub(DeployHelper, 'getReleaseId').returns 'rel'
        stub(DeployHelper, 'getEnvironmentId').returns 'env'
        @deployStub = stub(@client.resources.deployments, 'post')
        @deployStub.returns Promise.resolve({status: 200, body: 'deployments'})
      
      beforeEach (done) ->
        @room.user.say('alice', '@hubot octo deploy svc.me > 1.0.3 > prod').then =>
          done()           
      
      it 'should post deployment', () ->
        expect(@deployStub).to.have.been.called
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

helper = new Helper('../src/scripts/tasks.coffee')

describe 'hubot-octopus-deploy', ->
  before ->
    @client =
      resources:
        dashboard:
          get: stub()
        ,projects:
          id: stub()
    @octopusClient = stub OctopusClient, 'Create', =>
      @client

  beforeEach ->
    @room = helper.createRoom()

  after ->
    OctopusClient.Create.restore()

  afterEach ->
    @room.destroy()

  describe 'octo status', ->
    before ->
      releaseGet = stub()
      releaseGet.returns(Promise.resolve({status: 200, body: 'release'}))
      @client.resources.projects.id.returns({releases: {get: releaseGet}})
      @matchProjectsMock = stub(MatchProjects, 'find')

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
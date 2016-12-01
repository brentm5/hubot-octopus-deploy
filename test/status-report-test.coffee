fs = require 'fs'
path = require 'path'
testDashboardFile = path.join process.cwd(), 'test/dashboard-testdata.json'
testReleaseFile = path.join process.cwd(), 'test/release-testdata.json'
chai = require 'chai'
expect = chai.expect

subject = require '../src/status-report'

describe 'status-report', ->
  before () ->
    @dashboardData = JSON.parse(fs.readFileSync(testDashboardFile, 'utf8'))
    @releaseData = JSON.parse(fs.readFileSync(testReleaseFile, 'utf8'))
    
  describe 'createMapper', ->
    mapper = ''
    beforeEach ->
      mapper = subject.createMapper @dashboardData

    it 'should create a mapper function with the dashboard information', ->
      expect(mapper).to.be.a 'function'

    it 'should map to the correct project name', ->
      # Using projects-100
      testProject = @dashboardData.Projects[0]
      result = mapper testProject
      expect(result.name).to.equal testProject.Name

    it 'should map the environment\'s name, id, version and state info', ->
      # Using projects-100 test data
      testProject = @dashboardData.Projects[0]
      expectedEnvironment = @dashboardData.Environments[1]
      expectedRelease = @dashboardData.Items[0]

      result = mapper testProject
      resultEnv = result.environments[0]

      expect(resultEnv.name).to.equal expectedEnvironment.Name
      expect(resultEnv.id).to.equal expectedEnvironment.Id
      expect(resultEnv.version).to.equal expectedRelease.ReleaseVersion
      expect(resultEnv.state).to.equal expectedRelease.State

    it 'should only map environments with no release as unknown', ->
      # Using projects-100 test data
      testProject = @dashboardData.Projects[0]
      result = mapper testProject
      expect(result.environments[1].version).to.equal 'unknown'
      expect(result.environments[1].state).to.equal 'unknown'

    it 'should only map the most current releases', ->
      # Using Projects-201 test data
      testProject = @dashboardData.Projects[1]
      expectedSecondEnvironment = @dashboardData.Items[2]

      result = mapper testProject

      expect(result.environments[0].version).to.equal 'unknown'
      expect(result.environments[0].state).to.equal 'unknown'
      expect(result.environments[1].version).to.equal expectedSecondEnvironment.ReleaseVersion
      expect(result.environments[1].state).to.equal expectedSecondEnvironment.State

  describe 'extendWithLatestRelease', ->
    it 'should add the latest release under an environment called Release', ->
      # Order of collections must be align for it to zip together
      projects = [
        name: 'ShopCart.Service (no releases on environment but has latest on release-testdata)'
        environments: [
            name: 'DI'
            id: 'Environments-1'
            version: '0.0.1'
            state: 'unknown'
          ]
      ]
      releases = [
        @releaseData
      ]
      expectedRelease = @releaseData.Items[0]

      results = subject.extendWithLatestRelease projects, releases
      releaseEnvironment = results[0].environments[0]

      expect(releaseEnvironment.name).to.equal 'Latest'
      expect(releaseEnvironment.state).to.equal 'ok'
      expect(releaseEnvironment.version).to.equal expectedRelease.Version

_ = require 'lodash'

createGetEnvironments = (projectsGroup, environments) ->
  (projectGroupId) ->
    env = _.find projectsGroup, ['Id', projectGroupId]
    _.map env.EnvironmentIds, (envId) ->
      env = _.find environments, ['Id', envId]
      name: env.Name,
      id: env.Id

createGetReleases = (items) ->
  (projectId) ->
    _.filter items, {'ProjectId': projectId, 'IsCurrent': true}

module.exports =
  createMapper: (dashboard) ->
    groups = dashboard.ProjectGroups
    environments = dashboard.Environments
    getEnvironmentsByGroupId = createGetEnvironments groups, environments
    getReleasesByProjectId = createGetReleases dashboard.Items

    (project) ->
      environments = getEnvironmentsByGroupId project.ProjectGroupId
      releases = getReleasesByProjectId project.Id
      environments = _.map environments, (env) ->
        release = _.find releases, ['EnvironmentId', env.id]
        env.version = if release then release.ReleaseVersion else 'unknown'
        env.state = if release then release.State else 'unknown'
        env
      name: project.Name
      environments: environments

  extendWithLatestRelease: (projects, releases) ->
    _.zipWith projects, releases, (project, release) ->
      latestRelease =
        name: 'Latest'
        version: release.Items[0].Version
        state: 'ok'
      project.environments.unshift latestRelease
      project

  formatStatus: (statusReport) ->
    release = statusReport.name
    environment = "#{_.repeat(' ', release.length)}\t"
    statusReport.environments.forEach (env) ->
      versionLength = env.version.length
      environment = environment + "#{_.pad(env.name, versionLength + 5, ' ')}\t"
    statusReport.environments.forEach (env) ->
      state = _.toLower(_.trim(env.state))
      release = release + "\t" + "#{env.version} (#{state}) "
    environment + "\n" + release

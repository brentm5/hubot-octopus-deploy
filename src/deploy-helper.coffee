_ = require 'lodash'

module.exports =
  getProjectId: (project) ->
    project.Id
  getReleaseId: (list, version) ->
    items = list.Items
    item = _.find items, (item) ->
      item.Version.toUpperCase() == version.toUpperCase()
    item.Id
  getEnvironmentId: (list, env) ->
    items = list.Items
    item = _.find items, (item) ->
      item.Name.toUpperCase() == env.toUpperCase()
    item.Id
leven = require 'damerau-levenshtein'
_ = require 'lodash'

levenCompare = (criteria, projectName) ->
  leven criteria, projectName

contains = (criteria, projectName) ->
  projectName.indexOf projectName > -1
  
similarity = (result) ->
  result.leven.similarity

relative = (result) ->
  result.leven.relative

removeLevenAndIndex = (project) ->
  _.omit project, ['leven', 'containsCriteria']

module.exports =
  find: (projects, criteria) ->
    criteria = _.toLower(criteria.replace(/[.\-_]/g, ''))
    results = _(projects)
                .map (project) ->
                  projectName =  _.toLower(project.Name.replace(/[.\-_]/g, ''))
                  levenResult =
                    leven: levenCompare(criteria, projectName)
                  indexOf =
                    containsCriteria: contains(criteria, projectName)
                  _.assign project, levenResult, indexOf
                .orderBy(['containsCriteria', similarity, relative], ['desc', 'desc', 'asc'])
                .take(5)
                .map(removeLevenAndIndex)
                .value()       
    first = _.first results
    firstProjectName = _.toLower(first.Name.replace(/[.\-_]/g, ''))
    if levenCompare(criteria, firstProjectName).similarity is 1 then [first] else results
    
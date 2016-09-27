chai = require 'chai'
expect = chai.expect

subject = require '../src/match-projects'

describe 'match-projects', ->
  beforeEach ->
    @projects = [
      {Id: 1, Name: 'service.acme'},
      {Id: 2, Name: 'service.clothes.store'},
      {Id: 3, Name: 'service.ame'},
      {Id: 4, Name: 'service.bulk.store'},
      {Id: 5, Name: 'radio.station'},
      {Id: 6, Name: 'fake.service'},
      {Id: 7, Name: 'foo.bar.endpoint'},
      {Id: 8, Name: 'foo.acme.endpoint'}]

  context 'find', ->
    it 'should return one result for exact match', ->
      result = subject.find @projects, 'foo.bar.endpoint'
      expect(result).to.have.length 1
      expect(result[0].Id).to.equal 7
        
    it 'should match ignoring case and punctuation', ->
      result = subject.find @projects, 'foo-Bar.endpoint'
      expect(result).to.have.length 1
      expect(result[0].Id).to.equal 7
      
    it 'should return the top 5 matches', ->
      result = subject.find @projects, 'acme'
      expect(result).to.have.length 5
      expect(result).to.deep.include.members [{Id: 1, Name: 'service.acme'}, {Id: 3, Name: 'service.ame'}, {Id: 8, Name: 'foo.acme.endpoint'}]
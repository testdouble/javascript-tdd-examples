_ = require('lodash')

describe 'picksRandom', ->
  Given -> @subject = requireSubject('lib/picks-random')

  Then "nothing for undefined", -> @subject() == undefined
  Then "nothing for an empty list", -> @subject([]) == undefined

  context 'two items', ->
    When -> @result = _([0..1000]).map => @subject([1,2])
    Then -> _(@result).contains(1)
    And -> _(@result).contains(2)

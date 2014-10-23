describe 'getsProblem', ->
  Given -> @subject = requireSubject 'lib/gets-problem',
    './generates-problem': @generatesProblem = jasmine.createSpy('generatesProblem')
    './saves-problem': @savesProblem = jasmine.createSpy('savesProblem')
    './presents-problem': @presentsProblem = jasmine.createSpy('presentsProblem')

  Given -> @generatesProblem.andReturn("a problem")
  Given -> @savesProblem.when("a problem").thenReturn("a saved problem")
  Given -> @presentsProblem.when("a saved problem").thenReturn("a JSON problem")
  When -> @result = @subject()
  Then -> @result == "a JSON problem"

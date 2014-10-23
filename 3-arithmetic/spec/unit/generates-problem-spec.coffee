
describe 'generatesProblem', ->
  Given -> @subject = requireSubject 'lib/generates-problem',
    './picks-random': @picksRandom = jasmine.createSpy('picksRandom')

  Given -> @picksRandom.when([0..100]).thenReturn(5)
  Given -> @picksRandom.when(['+','-','*','/']).thenReturn("+")
  When -> @result = @subject()
  Then -> expect(@result).toEqual
    operands:
      left: 5
      right: 5
    operator: "+"

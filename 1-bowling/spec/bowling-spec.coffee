

describe 'Bowling', ->
  Given -> @subject = new Bowling()

  Given -> @rollMany = (pins, value) -> @subject.roll(value) for i in [0...pins]

  context 'gutter game', ->
    When -> @rollMany(20, 0)
    Then -> @subject.score() == 0

  context 'all 1 rolls', ->
    When -> @rollMany(20, 1)
    Then -> @subject.score() == 20

  context '1 spare', ->
    When -> @subject.roll(5)
    And -> @subject.roll(5)
    And -> @subject.roll(3)
    And -> @rollMany(17, 0)
    Then -> @subject.score() == 16

  context '1 not-spare split over two frames', ->
    When -> @subject.roll(0)
    And -> @subject.roll(5)
    And -> @subject.roll(5)
    And -> @subject.roll(3)
    And -> @rollMany(16, 0)
    Then -> @subject.score() == 13

  context '1 strike', ->
    When -> @subject.roll(10)
    And -> @subject.roll(3)
    And -> @subject.roll(4)
    And -> @rollMany(16, 0)
    Then -> @subject.score() == 24

  context 'Perfect game', ->
    When -> @rollMany(12, 10)
    Then -> @subject.score() == 300

class Bowling
  constructor: ->
    @rolls = []
    @currentRoll = 0

  roll: (pins) ->
    @rolls[@currentRoll++] = pins

  score: ->
    score = 0
    rollIndex = 0
    for frame in [0...10]
      if @isStrike(rollIndex)
        score += @rolls[rollIndex]
        score += @strikeBonus(rollIndex)
        rollIndex++
      else
        score += @rolls[rollIndex] + @rolls[rollIndex + 1]
        score += @spareBonus(rollIndex)
        rollIndex += 2
    score

  # private

  isStrike: (rollIndex) ->
    @rolls[rollIndex] == 10

  strikeBonus: (rollIndex) ->
    if @isStrike(rollIndex) then @rolls[rollIndex + 1] + @rolls[rollIndex + 2]

  spareBonus: (rollIndex) ->
    if @isSpare(rollIndex) then @rolls[rollIndex + 2] else 0

  isSpare: (rollIndex) ->
    @rolls[rollIndex] + @rolls[rollIndex] == 10

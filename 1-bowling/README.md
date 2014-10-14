# Bowling Kata

## Setup

1. If you haven't installed lineman yet, install it with `npm i -g lineman`.
2. Then, in separate terminals, start `lineman run` and `lineman spec`.
3. Create a new test file that we'll work from in spec/bowling-spec.coffee (if you wish you can use JS)

## The rules

Fetch this powerpoint from Uncle Bob's homepage [here](http://butunclebob.com/files/downloads/Bowling%20Game%20Kata.ppt).
The kata is designed to be closely followed, step-by-step.

## Test 1 - Gutter game

Write a single test specifying an API for a bowling game, adjusting the source at each step to change the message.

``` coffeescript
describe 'Bowling', ->
  Given -> @subject = new Bowling()
  Then -> #nothing

class Bowling
```

Then `roll` twenty gutter balls:

``` coffeescript
describe 'Bowling', ->
  Given -> @subject = new Bowling()
  When -> @subject.roll(0) for i in [0...20]
  Then -> #nothing

class Bowling
  roll: ->
```

Assert the score:

``` coffeescript
describe 'Bowling', ->
  Given -> @subject = new Bowling()
  When -> @subject.roll(0) for i in [0...20]
  Then -> @subject.score() == 0

class Bowling
  roll: ->

  score: -> 0
```

## Test 2 - all 1 pin rolls

Add a second failing test as a second 'context' for the object:

``` coffeescript
describe 'Bowling', ->
  context 'gutter game', ->
    Given -> @subject = new Bowling()
    When -> @subject.roll(0) for i in [0...20]
    Then -> @subject.score() == 0

  context 'all 1 rolls', ->
    Given -> @subject = new Bowling()
    When -> @subject.roll(1) for i in [0...20]
    Then -> @subject.score() == 20
```

Make the test pass by incrementing a value of score in the game object.

``` coffeescript
class Bowling
  constructor: ->
    @_score = 0

  roll: (pins) ->
    @_score += pins

  score: ->
    @_score
```

(Refactor pause)


Notice the duplicated loop in the test setup. You could DRY that up, like so:

``` coffeescript
describe 'Bowling', ->
  Given -> @subject = new Bowling()

  Given -> @rollMany = (pins, value) -> @subject.roll(value) for i in [0...pins]

  context 'gutter game', ->
    When -> @rollMany(20, 0)
    Then -> @subject.score() == 0

  context 'all 1 rolls', ->
    When -> @rollMany(20, 1)
    Then -> @subject.score() == 20
```

## Test 3 - a spare is rolled

To test how a spare is scored, we'll roll a single spare, take another roll, then roll gutters for the rest

Write the next failing test:

``` coffeescript
  context '1 spare', ->
    When -> @subject.roll(5)
    And -> @subject.roll(5)
    And -> @subject.roll(3)
    And -> @rollMany(17, 0)
    Then -> @subject.score() == 16
```

At this point, we realize that `roll()` calculates score, but name doesn't imply that. Meanwhile, `score()` implies calculation, but it's just an accessor method.
Instead of solving this directly, comment out the new test and refactor.

``` coffeescript
  # context '1 spare', ->
  #   When -> @subject.roll(5)
  #   And -> @subject.roll(5)
  #   And -> @subject.roll(3)
  #   And -> @rollMany(17, 0)
  #   Then -> @subject.score() == 16
```

Start by doing some scorekeeping before you break the existing game functionality:

``` coffeescript
class Bowling
  constructor: ->
    @_score = 0
    @rolls = []
    @currentRoll = 0

  roll: (pins) ->
    @_score += pins
    @rolls[@currentRoll++] = pins

  score: ->
    @_score
```

Next, finish the refactor by counting the score in the `score()` method:

``` coffeescript
class Bowling
  constructor: ->
    @rolls = []
    @currentRoll = 0

  roll: (pins) ->
    @rolls[@currentRoll++] = pins

  score: ->
    score = 0
    for roll in @rolls
      score += roll
    score
```

There's more we could do here, but before we refactor (read: optimize) the score method, let's
see how the spare case will complicate it.

So, uncomment the spare case:

``` coffeescript
  context '1 spare', ->
    When -> @subject.roll(5)
    And -> @subject.roll(5)
    And -> @subject.roll(3)
    And -> @rollMany(17, 0)
    Then -> @subject.score() == 16
```

Next, we might try this implementation:

``` coffeescript
  score: ->
    score = 0
    for roll, i in @rolls
      score += @rolls[i+2] if roll + @rolls[i+1] == 10
      score += roll
    score
```

This passes. But the above would identify would-be spares that are split over frames. For example, we could write a new test:

``` coffeescript
context '1 not-spare split over two frames', ->
  When -> @subject.roll(0)
  And -> @subject.roll(5)
  And -> @subject.roll(5)
  And -> @subject.roll(3)
  And -> @rollMany(16, 0)
  Then -> @subject.score() == 13
```

And this test would fail. So clearly our design isn't quite right. Instead, we should move frame-by-frame.

Commenting out the spare test for a moment, we could rework the `score` method for the current cases yet again:

``` coffeescript
  score: ->
    score = 0
    roll = 0
    for frame in [0...10]
      score += @rolls[roll] + @rolls[roll + 1]
      roll += 2
    score
```

Now we can get all four tests passing by adding the spare case to the loop:

``` coffeescript
  score: ->
    score = 0
    roll = 0
    for frame in [0...10]
      score += @rolls[roll] + @rolls[roll + 1]
      score += @rolls[roll + 2] if @rolls[roll] + @rolls[roll + 1] == 10
      roll += 2
    score
```

(Pause to refactor)

At this point, we might consider pulling out our postfix `if` statment to something with a descriptive name.

``` coffeescript
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
      score += @rolls[rollIndex] + @rolls[rollIndex + 1]
      score += @rolls[rollIndex + 2] if @isSpare(rollIndex)
      rollIndex += 2
    score

  # private

  isSpare: (rollIndex) ->
    @rolls[rollIndex] + @rolls[rollIndex] == 10
```

## Test 4 - 1 strike

Next, let's write a failing test for 1 strike bonus.

``` coffeescript
context '1 strike', ->
  When -> @subject.roll(10)
  And -> @subject.roll(3)
  And -> @subject.roll(4)
  And -> @rollMany(16, 0)
  Then -> @subject.score() == 24
```

To make that pass, we might write:

``` coffeescript
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
        score += @rolls[rollIndex + 1] + @rolls[rollIndex + 2]
        rollIndex++
      else
        score += @rolls[rollIndex] + @rolls[rollIndex + 1]
        score += @rolls[rollIndex + 2] if @isSpare(rollIndex)
        rollIndex += 2
    score

  # private

  isSpare: (rollIndex) ->
    @rolls[rollIndex] + @rolls[rollIndex] == 10

  isStrike: (rollIndex) ->
    @rolls[rollIndex] == 10
```

(Pause to refactor)

We could at least provide a name to all this bonus logic:

``` coffeescript
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

```

## Test 5 - Perfect game

Let's test a perfect game:

``` coffeescript
context 'Perfect game', ->
  When -> @rollMany(12, 10)
  Then -> @subject.score() == 300
```

Which, naturally, just passes without any modification to the code.

## Bonus round

What would this look like if you were to rewrite it functionally? Try using underscore/lodash/wutang/transducers to refactor the solution.

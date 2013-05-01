require '../../../test_helper'

describe 'Number::times', ->
  it 'should iterate the same count as the number', ->
    n = 0
    a = []
    5.times (i) ->
      n += 1
      a.push i

    expect(n).toBe(5)
    expect(a).toEqual([0,1,2,3,4])

  it 'should iterate the same count as the number absolute value', ->
    n = 0
    a = []
    5.3.times (i) ->
      n += 1
      a.push i

    expect(n).toBe(5)
    expect(a).toEqual([0,1,2,3,4])

  it 'should concatenates the passed-in string the right number of time', ->

    s = 5.times "*"
    expect(s).toBe("*****")

  it 'should multiply the passed-in number the right number of times', ->

    n = 5.times 2
    expect(n).toBe(10)

  it 'should concatenates the passed-in array the right number of times', ->

    a = 5.times ['foo', 10]
    expect(a).toEqual(['foo', 10,'foo', 10,'foo', 10,'foo', 10,'foo', 10])

describe 'Number::to', ->
  it 'should iterate positively from the number to the passed-in argument', ->
    n = 0
    a = []
    5.to 10, (i) ->
      n += 1
      a.push i

    expect(n).toBe(6)
    expect(a).toEqual([5,6,7,8,9,10])

  it 'should iterate negatively from the number to the passed-in argument', ->
    n = 0
    a = []
    5.to 0, (i) ->
      n += 1
      a.push i

    expect(n).toBe(6)
    expect(a).toEqual([5,4,3,2,1,0])

  it 'should iterate from the number to the passed-in argument
      evenv when the number has decimals'.squeeze(), ->
    n = 0
    a = []
    5.2.to 8.7, (i) ->
      n += 1
      a.push i

    expect(n).toBe(4)
    expect(a).toEqual([5.2, 6.2, 7.2, 8.2])

describe 'Number::even', ->
  it 'should returns true for even numbers', ->
    expect(0.even()).toBeTruthy()
    expect(2.even()).toBeTruthy()
    expect(-2.even()).toBeTruthy()
    expect(16.even()).toBeTruthy()

  it 'should returns false for odd numbers', ->
    expect(1.even()).toBeFalsy()
    expect(-1.even()).toBeFalsy()
    expect(3.even()).toBeFalsy()
    expect(17.even()).toBeFalsy()

describe 'Number::odd', ->
  it 'should returns true for odd numbers', ->
    expect(1.odd()).toBeTruthy()
    expect(-1.odd()).toBeTruthy()
    expect(3.odd()).toBeTruthy()
    expect(17.odd()).toBeTruthy()

  it 'should returns false for even numbers', ->
    expect(0.odd()).toBeFalsy()
    expect(-2.odd()).toBeFalsy()
    expect(2.odd()).toBeFalsy()
    expect(16.odd()).toBeFalsy()

describe 'Number::seconds', ->
  it 'should returns the number as seconds converted in milliseconds', ->
    expect(2.seconds()).toBe(2000)
    expect(-5.seconds()).toBe(-5000)
    expect(45.seconds()).toBe(45000)

describe 'Number::minutes', ->
  it 'should returns the number as minutes converted in milliseconds', ->
    expect(2.minutes()).toBe(2*60*1000)
    expect(-5.minutes()).toBe(-5*60*1000)
    expect(45.minutes()).toBe(45*60*1000)

describe 'Number::hours', ->
  it 'should returns the number as hours converted in milliseconds', ->
    expect(2.hours()).toBe(2*60*60*1000)
    expect(-5.hours()).toBe(-5*60*60*1000)
    expect(45.hours()).toBe(45*60*60*1000)

describe 'Number::days', ->
  it 'should returns the number as days converted in milliseconds', ->
    expect(2.days()).toBe(2*24*60*60*1000)
    expect(-5.days()).toBe(-5*24*60*60*1000)
    expect(45.days()).toBe(45*24*60*60*1000)

describe 'Number::weeks', ->
  it 'should returns the number as weeks converted in milliseconds', ->
    expect(2.weeks()).toBe(2*7*24*60*60*1000)
    expect(-5.weeks()).toBe(-5*7*24*60*60*1000)
    expect(45.weeks()).toBe(45*7*24*60*60*1000)

describe 'Number::fromNow', ->
  beforeEach -> addDateMatchers this
  it 'should returns a Date corresponding to the current time plus
      the current number as additional milliseconds'.squeeze(), ->

    d = new Date
    expect(2.hours().fromNow())
      .toEqualDate(new Date d.getTime() + 2*60*60*1000)

describe 'Number::ago', ->
  beforeEach -> addDateMatchers this
  it 'should return a Data corresponding to the current time minus
      the current number as milliseconds'.squeeze(), ->

    d = new Date
    expect(2.hours().ago())
      .toEqualDate(new Date d.getTime() - 2*60*60*1000)

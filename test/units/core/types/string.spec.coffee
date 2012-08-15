require '../../../test_helper'

describe 'String::squeeze', ->
  it 'should remove all duplicated spaces characters', ->
    s = 'i  r    r e\nl e\t\tv  a n\n\t t'
    expect(s.squeeze()).toBe('i r r e\nl e\tv a n\n\t t')

  it 'should remove all duplicated chars in the range', ->
    expect('irrellevvant'.squeeze 'm-z').toBe('irellevant')

  it 'should remove all duplicated instances of the passed-in string', ->
    expect('foofoobarbar'.squeeze 'foo').toBe('foobarbar')

describe 'String::capitalize', ->
  it 'should capitalize the first char of a string and leave the remainder
      in lower case'.squeeze(), ->
    expect('foo'.capitalize()).toBe('Foo')
    expect('bar BAZ'.capitalize()).toBe('Bar baz')
    expect('123ABC'.capitalize()).toBe('123abc')

describe 'String::capitalizeAll', ->
  it 'should capitalize the first char of each word in the string', ->
    expect('foo BAR bAz'.capitalizeAll()).toBe('Foo Bar Baz')

describe 'String::center', ->
  it 'should pads a string at both side to center the text', ->
    expect('foobar'.center 4).toBe('foobar')
    expect('foo'.center 10).toBe('   foo    ')
    expect('foo'.center 12, '123').toBe('1231foo12312')

describe 'String::prepend', ->
  it 'should prepend the passed-in string and retrun the result', ->
    expect('foo'.prepend 'bar').toBe('barfoo')

describe 'String::append', ->
  it 'should append the passed-in string and retrun the result', ->
    expect('foo'.append 'bar').toBe('foobar')

describe 'String::camelize', ->
  it 'should returns the camelized string', ->
    expect('foo_bar'.camelize()).toBe('fooBar')
    expect('FOO-bar'.camelize()).toBe('fooBar')
    expect('fOo BaR'.camelize()).toBe('fooBar')

describe 'String::to', ->
  it 'should iterates from the current char to the passed-in char', ->
    n = 0
    s = ''

    'a'.to 'z', (c) ->
      n += 1
      s += c

    expect(n).toBe(26)
    expect(s).toBe('abcdefghijklmnopqrstuvwxyz')

describe 'String::to', ->
  it 'should iterates from the current char to the passed-in char', ->
    n = 0
    s = ''

    'z'.to 'a', (c) ->
      n += 1
      s += c

    expect(n).toBe(26)
    expect(s).toBe('zyxwvutsrqponmlkjihgfedcba')

describe 'String::underscore', ->
  it 'should returns the string in underscore notation', ->
    expect('fooBar'.underscore()).toBe('foo_bar')
    expect('FooBar'.underscore()).toBe('foo_bar')
    expect('Foo BAR'.underscore()).toBe('foo_bar')
    expect('foo-BAR'.underscore()).toBe('foo_bar')
    expect('foo/BAR'.underscore()).toBe('foo_bar')

describe 'String::nodiacritics', ->
  it 'should remove the accented and ligature chars in the string', ->

    expect('ÉéÀàÈè'.nodiacritics()).toBe('EeAaEe')

describe 'String::nopunctuation', ->
  it 'should remove all punctuations from the string', ->

    expect('Something, is (wrong): in- this! !phrase?'.nopunctuation())
      .toBe('Something is wrong in this phrase')

describe 'String::parameterize', ->
  it 'should returns a string that look pretty in an url', ->

    expect('Béliqueux, le bougre!'.parameterize())
      .toBe('beliqueux-le-bougre')

describe 'String::strip', ->
  it 'should removes the spaces at both extremities of the string', ->

    expect('   foo'.strip()).toBe('foo')
    expect('foo   '.strip()).toBe('foo')

describe 'String::empty', ->
  it 'should returns true when the string has a length of 0', ->
    expect(''.empty()).toBeTruthy()
    expect('foo'.empty()).toBeFalsy()

describe 'String::left', ->
  it 'should pad a string on the right according to its length', ->
    expect('foo'.left 10).toBe('foo       ')
    expect('foobar'.left 10).toBe('foobar    ')

describe 'String::right', ->
  it 'should pad a string on the left according to its length', ->
    expect('foo'.right 10).toBe('       foo')
    expect('foobar'.right 10).toBe('    foobar')


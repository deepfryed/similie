require_relative 'helper'

describe 'Similie image load' do
  it 'should load image' do
    assert Similie.new(File.join($testdir, 'lena1.png'))
  end

  it 'should barf on invalid path' do
    assert_raises(ArgumentError) { Similie.new(File.join($testdir, 'foo')) }
  end

  it 'should hash image' do
    img = Similie.new(File.join($testdir, 'lena1.png'))
    assert img
    assert_equal 36170087496991428, img.fingerprint
  end

  it 'should hash image using class method' do
    hash = Similie.fingerprint(File.join($testdir, 'lena1.png'))
    assert hash
    assert_equal 36170087496991428, hash
  end

  it 'should expose popcount' do
    assert_equal 3, Similie.popcount(0x03 ^ 0x08)
    assert_equal 4, Similie.popcount(0x07 ^ 0x08)
  end
end

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
end

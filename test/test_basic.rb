require_relative 'helper'

describe 'Similie image load' do
  it 'should load image' do
    assert Similie.new(File.join($testdir, 'lena1.jpg'))
  end

  it 'should barf on invalid path' do
    assert_raises(ArgumentError) { Similie.new(File.join($testdir, 'lena2.jpg')) }
  end

  it 'should hash image' do
    img = Similie.new(File.join($testdir, 'lena1.jpg'))
    assert img
    assert_equal 216455360913932544, img.hash
  end
end

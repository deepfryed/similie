require 'similie'
require 'minitest/unit'
require 'minitest/spec'

$testdir = File.absolute_path(File.dirname(__FILE__))

MiniTest::Unit.autorun

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

describe 'Similie image distance' do
  it 'should work for similar images' do
    images = (1..5).map {|n| Similie.new(File.join($testdir, 'lena%d.png' % n ))}
    images.unshift nil

    assert_equal 2,  images[1].distance(images[2])
    assert_equal 9,  images[2].distance(images[3])
    assert_equal 8,  images[3].distance(images[4])
    assert_equal 1,  images[1].distance(images[4])
    assert_equal 12, images[1].distance(images[5])
  end

  it 'should work for similar images using % alias' do
    images = (1..5).map {|n| Similie.new(File.join($testdir, 'lena%d.png' % n ))}
    images.unshift nil

    assert_equal 2,  images[1] % images[2]
    assert_equal 9,  images[2] % images[3]
    assert_equal 8,  images[3] % images[4]
    assert_equal 1,  images[1] % images[4]
    assert_equal 12, images[1] % images[5]
  end

  it 'should work using the singleton method' do
    assert_equal 12, Similie.distance(File.join($testdir, 'lena1.png'), File.join($testdir, 'lena5.png'))
  end
end

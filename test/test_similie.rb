require 'similie'
require 'minitest/unit'
require 'minitest/spec'

$testdir = File.absolute_path(File.dirname(__FILE__))

MiniTest::Unit.autorun

describe 'Similie fingerprinting' do
  it 'should fingerprint image' do
    assert Similie.new.fingerprint(File.join($testdir, 'lena1.png'))
  end

  it 'should barf on invalid path' do
    assert_raises(ArgumentError){ Similie.new.fingerprint(File.join($testdir, 'foo')) }
  end

  it 'should barf on non image' do
    assert_raises(ArgumentError){ Similie.new.fingerprint(__FILE__) }
  end

  it 'should fingerprint image' do
    fingerprint = Similie.new.fingerprint(File.join($testdir, 'lena1.png'))
    assert_equal 36170087496991428, fingerprint
  end
end

describe 'Similie image distance' do
  it 'should work for similar images' do
    similie = Similie.new
    images = (1..5).map{ |n| File.join($testdir, 'lena%d.png' % n) }
    images.unshift nil

    assert_equal 2,  similie.distance(images[1], images[2])
    assert_equal 9,  similie.distance(images[2], images[3])
    assert_equal 8,  similie.distance(images[3], images[4])
    assert_equal 1,  similie.distance(images[1], images[4])
    assert_equal 12, similie.distance(images[1], images[5])
  end
end

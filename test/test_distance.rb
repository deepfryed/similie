require_relative 'helper'

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

  it 'should work using the singleton method' do
    assert_equal 12, Similie.distance(File.join($testdir, 'lena1.png'), File.join($testdir, 'lena5.png'))
  end
end

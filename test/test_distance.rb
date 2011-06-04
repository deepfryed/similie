require_relative 'helper'

describe 'Similie image distance' do
  it 'should work for similar images' do
    images = %w(lena1.jpg lena2.png lena3.png lena4.png lena5.jpg).map {|file| Similie.new(File.join($testdir, file))}

    assert_equal 1, images[0].distance(images[1])
    assert_equal 2, images[1].distance(images[2])
    assert_equal 0, images[2].distance(images[3])
    assert_equal 6, images[3].distance(images[4])
  end

  it 'should work using the singleton method' do
    assert_equal 6, Similie.distance(File.join($testdir, 'lena4.png'), File.join($testdir, 'lena5.jpg'))
  end
end

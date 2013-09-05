$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'ext')
require 'rspec'
require 'similie'
require 'pathname'

describe 'Similie fingerprinting' do
  DIR = Pathname(__FILE__).dirname

  it 'should fingerprint image' do
    expect(Similie.new.fingerprint(DIR + 'lena1.png')).not_to be(nil)
  end

  it 'should barf on invalid path' do
    expect{ Similie.new.fingerprint(DIR + 'foo') }.to raise_error(ArgumentError)
  end

  it 'should barf on non image' do
    expect{ Similie.new.fingerprint(__FILE__) }.to raise_error(ArgumentError)
  end

  it 'should fingerprint image' do
    fingerprint = Similie.new.fingerprint(DIR + 'lena1.png')
    expect(fingerprint).to eq(36170087496991428)
  end
end

describe 'Similie image distance' do
  it 'should work for similar images' do
    similie = Similie.new
    images = (1..5).map{ |n| DIR + 'lena%d.png' % n }
    images.unshift nil

    expect(similie.distance(images[1], images[2])).to eq(2)
    expect(similie.distance(images[2], images[3])).to eq(9)
    expect(similie.distance(images[3], images[4])).to eq(8)
    expect(similie.distance(images[1], images[4])).to eq(1)
    expect(similie.distance(images[1], images[5])).to eq(12)
  end
end

describe 'Similie caching' do
  it 'should use cache' do
    similie = Similie.new

    images = (1..5).map{ |n| DIR + 'lena%d.png' % n }

    images.each do |image|
      Similie::Fingerprint.should_receive(:fingerprint).once.with(image).and_return(image.__id__)
    end

    images.permutation(2) do |a, b|
      similie.distance(a, b)
    end
  end
end

describe 'Similie image reoriented distance' do
  it 'should work for identical but rotated images' do
    similie = Similie.new

    images = (0..7).map{ |n| DIR + 'rotation%d.png' % n }

    images.permutation(2) do |a, b|
      expect(similie.distance(a, b)).not_to eq(0)
      expect(similie.distance_with_rotations(a, b)).to eq(0)
    end
  end
end

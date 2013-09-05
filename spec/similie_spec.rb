$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'ext')
require 'rspec'
require 'similie'

$testdir = File.absolute_path(File.dirname(__FILE__))

describe 'Similie fingerprinting' do
  it 'should fingerprint image' do
    expect(Similie.new.fingerprint(File.join($testdir, 'lena1.png'))).not_to be(nil)
  end

  it 'should barf on invalid path' do
    expect{ Similie.new.fingerprint(File.join($testdir, 'foo')) }.to raise_error(ArgumentError)
  end

  it 'should barf on non image' do
    expect{ Similie.new.fingerprint(__FILE__) }.to raise_error(ArgumentError)
  end

  it 'should fingerprint image' do
    fingerprint = Similie.new.fingerprint(File.join($testdir, 'lena1.png'))
    expect(fingerprint).to eq(36170087496991428)
  end
end

describe 'Similie image distance' do
  it 'should work for similar images' do
    similie = Similie.new
    images = (1..5).map{ |n| File.join($testdir, 'lena%d.png' % n) }
    images.unshift nil

    expect(similie.distance(images[1], images[2])).to eq(2)
    expect(similie.distance(images[2], images[3])).to eq(9)
    expect(similie.distance(images[3], images[4])).to eq(8)
    expect(similie.distance(images[1], images[4])).to eq(1)
    expect(similie.distance(images[1], images[5])).to eq(12)
  end
end

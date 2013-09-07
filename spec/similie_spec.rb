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

  LENA1_FINGERPRINT = 11112265815244395537

  it 'should fingerprint image' do
    fingerprint = Similie.new.fingerprint(DIR + 'lena1.png')
    expect(fingerprint).to eq(LENA1_FINGERPRINT)
  end

  it 'should fingerprint image rotations' do
    rotations = Similie.new.rotations(DIR + 'lena1.png')
    expect(rotations[0]).to eq(LENA1_FINGERPRINT)
  end
end

describe 'Similie image distance' do
  it 'should work for similar images' do
    similie = Similie.new
    images = (1..5).map{ |n| DIR + 'lena%d.png' % n }
    images.unshift nil

    expect(similie.distance(images[1], images[2])).to eq(0)
    expect(similie.distance(images[2], images[3])).to eq(26)
    expect(similie.distance(images[3], images[4])).to eq(26)
    expect(similie.distance(images[1], images[4])).to eq(2)
    expect(similie.distance(images[1], images[5])).to eq(32)
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

describe 'Similie caching with rotations' do
  it 'should use cache' do
    similie = Similie.new

    images = (1..5).map{ |n| DIR + 'lena%d.png' % n }

    Similie::Fingerprint.should_receive(:fingerprint).exactly(images.length).times.and_return(0)
    Similie::Fingerprint.should_receive(:rotations).exactly(images.length - 1).times.and_return(8.times.to_a)

    images.permutation(2) do |a, b|
      similie.distance(a, b)
    end

    images.permutation(2) do |a, b|
      similie.distance_with_rotations(a, b)
    end

    images.permutation(2) do |a, b|
      similie.distance(a, b)
    end
  end

  it 'should calculate rotation fingerprints only when required' do
    similie = Similie.new

    images = (1..2).map{ |n| DIR + 'lena%d.png' % n }

    Similie::Fingerprint.should_receive(:fingerprint).once.with(images[0]).and_return(0)
    Similie::Fingerprint.should_receive(:rotations).once.with(images[0]).and_return(8.times.to_a)

    Similie::Fingerprint.should_receive(:fingerprint).once.with(images[1]).and_return(0)
    Similie::Fingerprint.should_not_receive(:rotations).with(images[1])

    similie.distance(images[0], images[1])
    similie.distance(images[1], images[0])
    similie.distance_with_rotations(images[0], images[1])
    similie.distance_with_rotations(images[1], images[0])
  end

  it 'should calculate rotation fingerprints when it should be more effective' do
    similie = Similie.new

    images = (1..2).map{ |n| DIR + 'lena%d.png' % n }

    Similie::Fingerprint.should_not_receive(:fingerprint).with(images[0])
    Similie::Fingerprint.should_receive(:rotations).once.with(images[0]).and_return(8.times.to_a)

    Similie::Fingerprint.should_not_receive(:fingerprint).with(images[0])
    Similie::Fingerprint.should_receive(:rotations).with(images[1]).and_return(8.times.to_a)

    similie.distance_with_rotations(images[0], images[1])
    similie.distance_with_rotations(images[1], images[0])
    similie.distance(images[0], images[1])
    similie.distance(images[1], images[0])
  end

end

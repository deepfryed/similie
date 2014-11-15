$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'ext')
require 'rspec'
require 'phamilie'
require 'pathname'

describe 'Phamilie fingerprinting' do
  DIR = Pathname(__FILE__).dirname

  it 'should fingerprint image' do
    expect(Phamilie.new.fingerprint(DIR + 'lena1.png')).not_to be(nil)
  end

  it 'should barf on invalid path' do
    expect{ Phamilie.new.fingerprint(DIR + 'foo') }.to raise_error(ArgumentError)
  end

  it 'should barf on non image' do
    expect{ Phamilie.new.fingerprint(__FILE__) }.to raise_error(ArgumentError)
  end

  LENA1_FINGERPRINT = 11112265815244395537

  it 'should fingerprint image' do
    fingerprint = Phamilie.new.fingerprint(DIR + 'lena1.png')
    expect(fingerprint).to eq(LENA1_FINGERPRINT)
  end

  it 'should fingerprint image rotations' do
    rotations = Phamilie.new.rotations(DIR + 'lena1.png')
    expect(rotations[0]).to eq(LENA1_FINGERPRINT)
  end
end

describe 'Phamilie image distance' do
  it 'should work for similar images' do
    phamilie = Phamilie.new
    images = (1..5).map{ |n| DIR + 'lena%d.png' % n }
    images.unshift nil

    expect(phamilie.distance(images[1], images[2])).to eq(0)
    expect(phamilie.distance(images[2], images[3])).to eq(26)
    expect(phamilie.distance(images[3], images[4])).to eq(26)
    expect(phamilie.distance(images[1], images[4])).to eq(2)
    expect(phamilie.distance(images[1], images[5])).to eq(32)
  end
end

describe 'Phamilie caching' do
  it 'should use cache' do
    phamilie = Phamilie.new

    images = (1..5).map{ |n| DIR + 'lena%d.png' % n }

    images.each do |image|
      expect(Phamilie::Fingerprint).to receive(:fingerprint).once.with(image).and_return(image.__id__)
    end

    images.permutation(2) do |a, b|
      phamilie.distance(a, b)
    end
  end
end

describe 'Phamilie image reoriented distance' do
  it 'should work for identical but rotated images' do
    phamilie = Phamilie.new

    images = (0..7).map{ |n| DIR + 'rotation%d.png' % n }

    images.permutation(2) do |a, b|
      expect(phamilie.distance(a, b)).not_to eq(0)
      expect(phamilie.distance_with_rotations(a, b)).to eq(0)
    end
  end
end

describe 'Phamilie caching with rotations' do
  it 'should use cache' do
    phamilie = Phamilie.new

    images = (1..5).map{ |n| DIR + 'lena%d.png' % n }

    expect(Phamilie::Fingerprint).to receive(:fingerprint).exactly(images.length).times.and_return(0)
    expect(Phamilie::Fingerprint).to receive(:rotations).exactly(images.length - 1).times.and_return(8.times.to_a)

    images.permutation(2) do |a, b|
      phamilie.distance(a, b)
    end

    images.permutation(2) do |a, b|
      phamilie.distance_with_rotations(a, b)
    end

    images.permutation(2) do |a, b|
      phamilie.distance(a, b)
    end
  end

  it 'should calculate rotation fingerprints only when required' do
    phamilie = Phamilie.new

    images = (1..2).map{ |n| DIR + 'lena%d.png' % n }

    expect(Phamilie::Fingerprint).to receive(:fingerprint).once.with(images[0]).and_return(0)
    expect(Phamilie::Fingerprint).to receive(:rotations).once.with(images[0]).and_return(8.times.to_a)

    expect(Phamilie::Fingerprint).to receive(:fingerprint).once.with(images[1]).and_return(0)
    expect(Phamilie::Fingerprint).not_to receive(:rotations).with(images[1])

    phamilie.distance(images[0], images[1])
    phamilie.distance(images[1], images[0])
    phamilie.distance_with_rotations(images[0], images[1])
    phamilie.distance_with_rotations(images[1], images[0])
  end

  it 'should calculate rotation fingerprints when it should be more effective' do
    phamilie = Phamilie.new

    images = (1..2).map{ |n| DIR + 'lena%d.png' % n }

    expect(Phamilie::Fingerprint).not_to receive(:fingerprint).with(images[0])
    expect(Phamilie::Fingerprint).to receive(:rotations).once.with(images[0]).and_return(8.times.to_a)

    expect(Phamilie::Fingerprint).not_to receive(:fingerprint).with(images[0])
    expect(Phamilie::Fingerprint).to receive(:rotations).with(images[1]).and_return(8.times.to_a)

    phamilie.distance_with_rotations(images[0], images[1])
    phamilie.distance_with_rotations(images[1], images[0])
    phamilie.distance(images[0], images[1])
    phamilie.distance(images[1], images[0])
  end

end

class Similie
  def fingerprint(path)
    Fingerprint.fingerprint(path)
  end

  def distance(path_a, path_b)
    Fingerprint.distance(fingerprint(path_a), fingerprint(path_b))
  end
end

require 'similie/fingerprint.so'

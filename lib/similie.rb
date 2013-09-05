class Similie
  def initialize(cache = {})
    {:[] => 1, :[]= => 2}.each do |method, desired_arity|
      unless cache.respond_to?(method)
        raise ArgumentError.new("#{cache} does not respond to #{method}")
      end

      arity = cache.method(method).arity
      unless arity == desired_arity
        raise ArgumentError.new("#{cache} method #{method} arity should be #{desired_arity} instead of #{arity}")
      end
    end

    @cache = cache
  end

  def fingerprint(path)
    case cached = @cache[path]
    when Array
      cached[0]
    when Integer
      cached
    when nil
      @cache[path] = Fingerprint.fingerprint(path)
    else
      raise "Cache for #{path} contains non fingerprint #{cached}"
    end
  end

  def rotations(path)
    case cached = @cache[path]
    when Array
      cached
    when Integer, nil
      @cache[path] = Fingerprint.rotations(path)
    else
      raise "Cache for #{path} contains non fingerprint #{cached}"
    end
  end

  def distance(path_a, path_b)
    Fingerprint.distance(fingerprint(path_a), fingerprint(path_b))
  end

  def distance_with_rotations(path_a, path_b)
    fingerprint_a = rotations(path_a)[0]
    rotations(path_b).map do |rotation_b|
      Fingerprint.distance(fingerprint_a, rotation_b)
    end.min
  end
end

require 'similie/fingerprint.so'

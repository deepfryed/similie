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
    @cache[path] ||= Fingerprint.fingerprint(path)
  end

  def distance(path_a, path_b)
    Fingerprint.distance(fingerprint(path_a), fingerprint(path_b))
  end
end

require 'similie/fingerprint.so'

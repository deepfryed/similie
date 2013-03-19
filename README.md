# Similie

Similie is a simple DCT based image hashing interface that,

* computes a fingerprint based on low frequencies of an image.
* computes hamming distance between 2 fingerprints.

## Example

```ruby
  require 'similie'

  img1 = Similie.new("test/lena1.png")
  img2 = Similie.new("test/lena2.png") # lena1.png cropped and scaled
  img3 = Similie.new("test/lena5.png") # a different image

  img1.fingerprint #=> 64bit int

  img1.distance(img2) #=> 2
  img1.distance(img3) #=> 12

  # class methods, if you want to deallocate image buffers immediately.
  Similie.distance("test/lena1.png", "test/lena5.png") #=> 12
  Similie.fingerprint("test/lena1.png")

  # utility method that exposes hamming distance http://en.wikipedia.org/wiki/Hamming_weight
  Similie.popcount(0x03 ^ 0x08) #=> 3
```

## Dependencies

* ruby 1.9.1+
* opencv 2.1+  (libcv-dev and libhighgui-dev on debian systems)

# See Also

[pHash - The open source perceptual hash library](http://www.phash.org/)

# License

MIT

# Similie

Similie is a simple DCT based image hashing interface that,

* computes a fingerprint based on low frequencies of an image.
* computes hamming distance between 2 fingerprints.

## Example

```ruby
  require 'similie'

  similie = Similie.new

  lena1 = "spec/lena1.png"
  lena2 = "spec/lena2.png" # lena1.png cropped and scaled
  lena5 = "spec/lena5.png" # a different image
  lena6 = "spec/lena6.png" # lena2.png rotated and scaled

  similie.fingerprint(lena1) #=> 36170087496991428

  similie.distance(lena1, lena2) #=> 2
  similie.distance(lena1, lena5) #=> 12

  similie.distance(lena1, lena6) #=> 19
  similie.distance(lena2, lena6) #=> 19
  similie.distance(lena5, lena6) #=> 23
  similie.distance_with_rotations(lena1, lena6) #=> 2
  similie.distance_with_rotations(lena2, lena6) #=> 0
  similie.distance_with_rotations(lena5, lena6) #=> 12
```

## Caching

By default a Hash is used to cache fingerprints by path. Be carefull if images or current directory can change in process.

As cache you can use an instance of class responding to `[]` and `[]=`.

If using persistant cache take into account file size and mtime or even cryptographic hash of contents.

## Dependencies

* ruby 1.9.1+
* CImg

# License

GPL — using code from pHash library

# Similie

Similie is a simple DCT based image hashing interface that,

* computes a fingerprint based on low frequencies of an image.
* computes hamming distance between 2 fingerprints.

## Example

```ruby
  require 'similie'

  similie = Similie.new

  img_path1 = "test/lena1.png"
  img_path2 = "test/lena2.png" # lena1.png cropped and scaled
  img_path3 = "test/lena5.png" # a different image

  similie.fingerprint(img_path1) #=> 36170087496991428

  similie.distance(img_path1, img_path2) #=> 2
  similie.distance(img_path1, img_path3) #=> 12
```

## Caching

By default a Hash is used to cache fingerprints by path. Be carefull if images or current directory can change in process.

As cache you can use an instance of class responding to `[]` and `[]=`.

If using persistant cache take into account file size and mtime or even cryptographic hash of contents.

## Dependencies

* ruby 1.9.1+
* opencv 2.1+  (libcv-dev and libhighgui-dev on debian systems)

# See Also

[pHash - The open source perceptual hash library](http://www.phash.org/)

# License

MIT

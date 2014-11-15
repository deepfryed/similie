# Phamilie

Originally forked from [deepfryed/similie](https://github.com/deepfryed/similie).

Phamilie is a simple DCT based image hashing interface that,

* computes a fingerprint based on low frequencies of an image.
* computes hamming distance between 2 fingerprints.

## Example

```ruby
require 'phamilie'

phamilie = Phamilie.new

lena1 = 'spec/lena1.png'
lena2 = 'spec/lena2.png' # lena1.png cropped and scaled
lena5 = 'spec/lena5.png' # a different image
lena6 = 'spec/lena6.png' # lena2.png rotated and scaled

phamilie.fingerprint(lena1) #=> 36170087496991428

phamilie.distance(lena1, lena2) #=> 2
phamilie.distance(lena1, lena5) #=> 12

phamilie.distance(lena1, lena6) #=> 19
phamilie.distance(lena2, lena6) #=> 19
phamilie.distance(lena5, lena6) #=> 23
phamilie.distance_with_rotations(lena1, lena6) #=> 2
phamilie.distance_with_rotations(lena2, lena6) #=> 0
phamilie.distance_with_rotations(lena5, lena6) #=> 12
```

## Caching

By default a Hash is used to cache fingerprints by path. Be carefull if images or current directory can change in process.

As cache you can use an instance of class responding to `[]` and `[]=`.

If using persistant cache take into account file size and mtime or even cryptographic hash of contents.

## Dependencies

* ruby 1.9.1+
* CImg
* libpng if you need to read png images
* libjpeg if you need to read jpeg images
* ImageMagick if you need to read other images

# License

GPL — using code from pHash library

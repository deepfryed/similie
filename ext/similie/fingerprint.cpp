/*
    (c) Bharanee Rathna 2011

    CC BY-SA 3.0
    http://creativecommons.org/licenses/by-sa/3.0/

    Free for every type of use. The author cannot be legally held responsible for
    any damages resulting from the use of this work. All modifications or derivatives
    need to be attributed.
*/

#include <ruby.h>
#include <ruby/encoding.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define cimg_display 0
#define cimg_verbosity 0
#include "CImg.h"
using namespace cimg_library;

#define TO_S(v)    rb_funcall(v, rb_intern("to_s"), 0)
#define CSTRING(v) RSTRING_PTR(TO_S(v))

#undef SIZET2NUM
#undef NUM2SIZET

#ifdef HAVE_LONG_LONG
  #define SIZET2NUM(x) ULL2NUM(x)
  #define NUM2SIZET(x) NUM2ULL(x)
#else
  #define SIZET2NUM(x) ULONG2NUM(x)
  #define NUM2SIZET(x) NUM2ULONG(x)
#endif

#define DCT_SIZE 32

#if __GNUC__ > 3 || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4)
#define popcount __builtin_popcountll
#else
// http://en.wikipedia.org/wiki/Hamming_weight

const uint64_t m1  = 0x5555555555555555; //binary: 0101...
const uint64_t m2  = 0x3333333333333333; //binary: 00110011..
const uint64_t m4  = 0x0f0f0f0f0f0f0f0f; //binary:  4 zeros,  4 ones ...
const uint64_t h01 = 0x0101010101010101; //the sum of 256 to the power of 0,1,2,3...

int popcount(uint64_t x) {
  x -= (x >> 1) & m1;             //put count of each 2 bits into those 2 bits
  x = (x & m2) + ((x >> 2) & m2); //put count of each 4 bits into those 4 bits
  x = (x + (x >> 4)) & m4;        //put count of each 8 bits into those 8 bits
  return (x * h01)>>56;           //returns left 8 bits of x + (x<<8) + (x<<16) + (x<<24) + ...
}
#endif

CImg<float>* ph_dct_matrix(const int N) {
  CImg<float> *ptr_matrix = new CImg<float>(N, N, 1, 1, 1 / sqrt((float) N));
  const float c1 = sqrt(2.0 / N);
  for (int x = 0; x < N; x++){
    for (int y = 1; y < N; y++){
      *ptr_matrix->data(x, y) = c1 * cos((cimg::PI / 2 / N) * y * (2 * x + 1));
    }
  }
  return ptr_matrix;
}

void small_mono_image(CImg<uint8_t> &img, CImg<float> &small) {
  CImg<float> meanfilter(7, 7, 1, 1, 1);
  if (img.spectrum() == 3){
    small = img.RGBtoYCbCr().channel(0).get_convolve(meanfilter);
  } else if (img.spectrum() == 4){
    int width = img.width();
    int height = img.height();
    small = img.crop(0, 0, 0, 0, width - 1, height - 1, 0, 2).RGBtoYCbCr().channel(0).get_convolve(meanfilter);
  } else {
    small = img.channel(0).get_convolve(meanfilter);
  }
  small.resize(32, 32, -100, -100, 2);
}

uint64_t small_mono_image_fingerprint(CImg<float> &small) {
  uint64_t hash;

  CImg<float> *C  = ph_dct_matrix(32);
  CImg<float> Ctransp = C->get_transpose();
  CImg<float> dctImage = (*C) * small * Ctransp;
  CImg<float> subsec = dctImage.crop(1, 1, 8, 8).unroll('x');

  float median = subsec.median();
  uint64_t one = 0x0000000000000001;
  hash = 0x0000000000000000;
  for (int i = 0; i < 64; i++){
    float current = subsec(i);
    if (current > median)
      hash |= one;
    one = one << 1;
  }

  delete C;

  return hash;
}

uint64_t image_fingerprint(CImg<uint8_t> &image) {
  CImg<float> small;

  small_mono_image(image, small);

  return small_mono_image_fingerprint(small);
}

void image_rotation_fingerprints(CImg<uint8_t> &image, uint64_t* phashs) {
  static int a = 0;

  CImg<float> small;

  small_mono_image(image, small);

  phashs[0] = small_mono_image_fingerprint(small);

  small.mirror('x');
  phashs[1] = small_mono_image_fingerprint(small);

  small.mirror('y');
  phashs[2] = small_mono_image_fingerprint(small);

  small.mirror('x');
  phashs[3] = small_mono_image_fingerprint(small);

  small.transpose();
  phashs[4] = small_mono_image_fingerprint(small);

  small.mirror('x');
  phashs[5] = small_mono_image_fingerprint(small);

  small.mirror('y');
  phashs[6] = small_mono_image_fingerprint(small);

  small.mirror('x');
  phashs[7] = small_mono_image_fingerprint(small);
}

VALUE rb_image_fingerprint_func(VALUE self, VALUE file) {
  CImg<uint8_t> img;
  try {
    img.load(CSTRING(file));
  } catch (CImgIOException ex){
    rb_raise(rb_eArgError, "Invalid image or unsupported format: %s", CSTRING(file));
  }

  uint64_t phash = image_fingerprint(img);

  return SIZET2NUM(phash);
}

VALUE rb_image_rotation_fingerprints_func(VALUE self, VALUE file) {
  CImg<uint8_t> img;
  try {
    img.load(CSTRING(file));
  } catch (CImgIOException ex){
    rb_raise(rb_eArgError, "Invalid image or unsupported format: %s", CSTRING(file));
  }

  uint64_t phashs[8] = {};
  image_rotation_fingerprints(img, phashs);

  VALUE rotations = rb_ary_new();

  for (int i = 0; i < 8; i++) {
    rb_ary_push(rotations, SIZET2NUM(phashs[i]));
  }

  return rotations;
}

VALUE rb_fingerprint_distance_func(VALUE self, VALUE fingerprint1, VALUE fingerprint2) {
  if (TYPE(fingerprint1) != T_BIGNUM && TYPE(fingerprint1) != T_FIXNUM)
    rb_raise(rb_eArgError, "fingerprint1 needs to be a number");

  if (TYPE(fingerprint2) != T_BIGNUM && TYPE(fingerprint2) != T_FIXNUM)
    rb_raise(rb_eArgError, "fingerprint2 needs to be a number");

  int dist = popcount(NUM2SIZET(fingerprint1) ^ NUM2SIZET(fingerprint2));

  return INT2NUM(dist);
}

extern "C" {
  void Init_fingerprint() {
    VALUE cSimilie = rb_define_class("Similie", rb_cObject);
    VALUE mFingerprint = rb_define_module_under(cSimilie, "Fingerprint");

    rb_define_singleton_method(mFingerprint, "fingerprint", RUBY_METHOD_FUNC(rb_image_fingerprint_func),            1);
    rb_define_singleton_method(mFingerprint, "rotations",   RUBY_METHOD_FUNC(rb_image_rotation_fingerprints_func),  1);
    rb_define_singleton_method(mFingerprint, "distance",    RUBY_METHOD_FUNC(rb_fingerprint_distance_func),         2);
  }
}

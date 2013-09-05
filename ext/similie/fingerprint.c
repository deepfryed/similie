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
#include <opencv/cv.h>
#include <opencv/cxcore.h>
#include <opencv/highgui.h>

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
const uint64_t m8  = 0x00ff00ff00ff00ff; //binary:  8 zeros,  8 ones ...
const uint64_t m16 = 0x0000ffff0000ffff; //binary: 16 zeros, 16 ones ...
const uint64_t m32 = 0x00000000ffffffff; //binary: 32 zeros, 32 ones
const uint64_t hff = 0xffffffffffffffff; //binary: all ones
const uint64_t h01 = 0x0101010101010101; //the sum of 256 to the power of 0,1,2,3...

int popcount(uint64_t x) {
  x -= (x >> 1) & m1;             //put count of each 2 bits into those 2 bits
  x = (x & m2) + ((x >> 2) & m2); //put count of each 4 bits into those 4 bits
  x = (x + (x >> 4)) & m4;        //put count of each 8 bits into those 8 bits
  return (x * h01)>>56;           //returns left 8 bits of x + (x<<8) + (x<<16) + (x<<24) + ...
}
#endif

uint64_t image_fingerprint(IplImage *img) {
  int x, y;
  double avg = 0;
  uint64_t phash = 0, phash_mask = 1;

  IplImage *mono  = cvCreateImage(cvSize(img->width, img->height), img->depth, 1);
  IplImage *small = cvCreateImage(cvSize(DCT_SIZE, DCT_SIZE),      img->depth, 1);

  img->nChannels == 1 ? cvCopy(img, mono, 0) : cvCvtColor(img, mono, CV_RGB2GRAY);
  cvResize(mono, small, CV_INTER_CUBIC);

  CvMat *dct = cvCreateMat(DCT_SIZE, DCT_SIZE, CV_64FC1);

  cvConvertScale(small, dct, 1, 0);
  cvTranspose(dct, dct);

  cvDCT(dct, dct, CV_DXT_ROWS);
  cvSet2D(dct, 0, 0, cvScalarAll(0));

  CvMat roi;
  cvGetSubRect(dct, &roi, cvRect(0, 0, 8, 8));
  avg = cvAvg(&roi, 0).val[0] * 64.0 / 63.0;

  for (x = 7; x >= 0; x--) {
    for (y = 7; y >= 0; y--) {
      if (cvGet2D(dct, x, y).val[0] > avg)
        phash |= phash_mask;
      phash_mask = phash_mask << 1;
    }
  }

  cvReleaseMat(&dct);
  cvReleaseImage(&mono);
  cvReleaseImage(&small);
  return phash;
}

VALUE rb_image_fingerprint_func(VALUE self, VALUE file) {
  IplImage *img;
  img = cvLoadImage(CSTRING(file), -1);
  if (!img)
    rb_raise(rb_eArgError, "Invalid image or unsupported format: %s", CSTRING(file));

  uint64_t phash = image_fingerprint(img);
  cvReleaseImage(&img);

  return SIZET2NUM(phash);
}

VALUE rb_image_distance_func(VALUE self, VALUE file1, VALUE file2) {
  IplImage *img1, *img2;
  img1 = cvLoadImage(CSTRING(file1), -1);
  if (!img1)
    rb_raise(rb_eArgError, "Invalid image or unsupported format: %s", CSTRING(file1));

  img2 = cvLoadImage(CSTRING(file2), -1);
  if (!img2) {
    cvReleaseImage(&img1);
    rb_raise(rb_eArgError, "Invalid image or unsupported format: %s", CSTRING(file2));
  }

  int dist = popcount(image_fingerprint(img1) ^ image_fingerprint(img2));

  cvReleaseImage(&img1);
  cvReleaseImage(&img2);

  return INT2NUM(dist);
}

VALUE rb_popcount_func(VALUE self, VALUE value) {
  if (TYPE(value) != T_BIGNUM && TYPE(value) != T_FIXNUM)
    rb_raise(rb_eArgError, "value needs to be a number");
  return INT2NUM(popcount(NUM2INT(value)));
}

void Init_fingerprint() {
  VALUE cSimilie = rb_define_class("Similie", rb_cObject);
  VALUE cFingerprint = rb_define_class("Fingerprint", cSimilie);

  rb_define_singleton_method(cFingerprint, "fingerprint", RUBY_METHOD_FUNC(rb_image_fingerprint_func), 1);
  rb_define_singleton_method(cFingerprint, "distance",    RUBY_METHOD_FUNC(rb_image_distance_func),    2);
  rb_define_singleton_method(cFingerprint, "popcount",    RUBY_METHOD_FUNC(rb_popcount_func),          1);
}

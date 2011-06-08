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

#define TO_S(v)                    rb_funcall(v, rb_intern("to_s"), 0)
#define CSTRING(v)                 RSTRING_PTR(TO_S(v))
#define ID_CONST_GET               rb_intern("const_get")
#define CONST_GET(scope, constant) (rb_funcall(scope, ID_CONST_GET, 1, rb_str_new2(constant)))
#define cvGetMonoPixel(img,y,x)    ((uchar *)(img->imageData + x*img->widthStep))[y*img->nChannels]

#undef SIZET2NUM
#ifdef HAVE_LONG_LONG
  #define SIZET2NUM(x) ULL2NUM(x)
#else
  #define SIZET2NUM(x) ULONG2NUM(x)
#endif

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

#define DCT_SIZE 32

uint64_t image_phash(IplImage *img) {
    int x, y;
    double avg = 0;
    uint64_t phash = 0, phash_mask = 1;

    IplImage *small = cvCreateImage(cvSize(DCT_SIZE, DCT_SIZE), img->depth, img->nChannels);
    IplImage *mono  = cvCreateImage(cvSize(DCT_SIZE, DCT_SIZE), img->depth, 1);

    cvResize(img, small, CV_INTER_CUBIC);
    img->nChannels == 1 ? cvCopy(small, mono, 0) : cvCvtColor(small, mono, CV_RGB2GRAY);

    CvMat *dct = cvCreateMat(DCT_SIZE, DCT_SIZE, CV_32FC1);
    for (x = 0; x < DCT_SIZE; x++) {
        for (y = 0; y < DCT_SIZE; y++) {
            cvSet2D(dct, x, y, cvScalarAll(cvGetMonoPixel(mono, x, y)));
        }
    }

    cvDCT(dct, dct, CV_DXT_ROWS);
    cvSet2D(dct, 0, 0, cvScalarAll(0));

    for (y = 0; y < 8; y++) {
        for (x = 0; x < 8; x++) {
            avg += cvGet2D(dct, x, y).val[0];
        }
    }

    avg /= 63.0;

    for (x = 7; x >= 0; x--) {
        for (y = 7; y >= 0; y--) {
            if (cvGet2D(dct, x, y).val[0] > avg) phash |= phash_mask;
            phash_mask = phash_mask << 1;
        }
    }

    phash = phash & 0x7FFFFFFFFFFFFFFF;

    cvReleaseMat(&dct);
    cvReleaseImage(&mono);
    cvReleaseImage(&small);
    return phash;
}

static void rb_image_free(IplImage *handle) {
  if (handle)
    cvReleaseImage(&handle);
}

VALUE rb_image_alloc(VALUE klass) {
  IplImage *handle = 0;
  return Data_Wrap_Struct(klass, 0, rb_image_free, handle);
}

IplImage* rb_image_handle(VALUE self) {
  IplImage *handle = 0;
  Data_Get_Struct(self, IplImage, handle);
  if (!handle)
    rb_raise(rb_eRuntimeError, "Invalid object, did you forget to call super() ?");

  return handle;
}

VALUE rb_image_hash(VALUE self) {
    VALUE hash = rb_iv_get(self, "@hash");
    if (NIL_P(hash)) {
        hash = SIZET2NUM(image_phash(rb_image_handle(self)));
        rb_iv_set(self, "@hash", hash);
    }
    return hash;
}

VALUE rb_image_initialize(VALUE self, VALUE file) {
    IplImage *img = cvLoadImage(CSTRING(file), -1);
    if (!img)
        rb_raise(rb_eArgError, "Invalid image or unsupported format: %s", CSTRING(file));

    DATA_PTR(self) = img;
    return self;
}


VALUE rb_image_distance(VALUE self, VALUE other) {
    VALUE hash1 = rb_image_hash(self);
    VALUE hash2 = rb_image_hash(other);
    int dist    = popcount(NUM2ULONG(hash1) ^ NUM2ULONG(hash2));
    return INT2NUM(dist);
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

    int dist = popcount(image_phash(img1) ^ image_phash(img2));

    cvReleaseImage(&img1);
    cvReleaseImage(&img2);

    return INT2NUM(dist);
}

VALUE rb_image_phash_func(VALUE self, VALUE file) {
    IplImage *img;
    img = cvLoadImage(CSTRING(file), -1);
    if (!img)
        rb_raise(rb_eArgError, "Invalid image or unsupported format: %s", CSTRING(file));

    uint64_t phash = image_phash(img);
    cvReleaseImage(&img);

    return SIZET2NUM(phash);
}

void Init_similie() {
    VALUE cSimilie = rb_define_class("Similie", rb_cObject);
    rb_define_alloc_func(cSimilie, rb_image_alloc);
    rb_define_method(cSimilie, "initialize", RUBY_METHOD_FUNC(rb_image_initialize), 1);
    rb_define_method(cSimilie, "hash",       RUBY_METHOD_FUNC(rb_image_hash),       0);
    rb_define_method(cSimilie, "distance",   RUBY_METHOD_FUNC(rb_image_distance),   1);

    rb_define_singleton_method(cSimilie, "distance", RUBY_METHOD_FUNC(rb_image_distance_func), 2);
    rb_define_singleton_method(cSimilie, "phash",    RUBY_METHOD_FUNC(rb_image_phash_func),    1);
}

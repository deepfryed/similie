/*
    (c) Bharanee Rathna 2011

    CC BY-SA 3.0
    http://creativecommons.org/licenses/by-sa/3.0/

    Free for every type of use. The author cannot be legally held responsible for
    any damages resulting from the use of this work. All modifications or derivatives
    need to be attributed.
*/

#include <ruby.h>

extern "C" {
  #include <ruby/encoding.h>
}

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include "pHash.h"

#define TO_S(v)                    rb_funcall(v, rb_intern("to_s"), 0)
#define CSTRING(v)                 RSTRING_PTR(TO_S(v))
#define ID_CONST_GET               rb_intern("const_get")
#define CONST_GET(scope, constant) (rb_funcall(scope, ID_CONST_GET, 1, rb_str_new2(constant)))

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

uint64_t image_phash(VALUE file) {
    ulong64 hash;

    try {
      ph_dct_imagehash(CSTRING(file), hash);
    }
    catch(CImgException &e) {
      rb_raise(rb_eRuntimeError, "%s", e.what());
    }

    return (uint64_t) hash & 0x7FFFFFFFFFFFFFFF;
}

VALUE rb_image_hash(VALUE self) {
    VALUE hash = rb_iv_get(self, "@hash");
    if (NIL_P(hash)) {
        hash = SIZET2NUM(image_phash(rb_iv_get(self, "@file")));
        rb_iv_set(self, "@hash", hash);
    }
    return hash;
}

VALUE rb_image_initialize(VALUE self, VALUE file) {
    rb_io_close(rb_file_open(CSTRING(file), "r"));
    rb_iv_set(self, "@file", file);
    return self;
}

VALUE rb_image_distance(VALUE self, VALUE other) {
    VALUE hash1 = rb_image_hash(self);
    VALUE hash2 = rb_image_hash(other);
    int dist    = popcount(NUM2ULONG(hash1) ^ NUM2ULONG(hash2));
    return INT2NUM(dist);
}

VALUE rb_image_distance_func(VALUE self, VALUE file1, VALUE file2) {
    rb_io_close(rb_file_open(CSTRING(file1), "r"));
    rb_io_close(rb_file_open(CSTRING(file2), "r"));
    return INT2NUM(popcount(image_phash(file1) ^ image_phash(file2)));
}

VALUE rb_image_phash_func(VALUE self, VALUE file) {
    rb_io_close(rb_file_open(CSTRING(file), "r"));
    return SIZET2NUM(image_phash(file));
}


extern "C" {
    void Init_similie() {
      VALUE cSimilie = rb_define_class("Similie", rb_cObject);
        rb_define_method(cSimilie, "initialize", RUBY_METHOD_FUNC(rb_image_initialize), 1);
        rb_define_method(cSimilie, "hash",       RUBY_METHOD_FUNC(rb_image_hash),       0);
        rb_define_method(cSimilie, "distance",   RUBY_METHOD_FUNC(rb_image_distance),   1);

        rb_define_singleton_method(cSimilie, "distance", RUBY_METHOD_FUNC(rb_image_distance_func), 2);
        rb_define_singleton_method(cSimilie, "phash",    RUBY_METHOD_FUNC(rb_image_phash_func),    1);
    }
}

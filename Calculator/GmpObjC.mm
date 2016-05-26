//
//  GmpObjC.mm
//  Calculator
//
//  Created by Joachim Neumann on 23/05/16.
//  Copyright © 2016 VISAMED IT. All rights reserved.
//


#include <mpfr.h>
#import "GmpObjC.h"

@interface GmpObjC () {
    mpfr_t mpfr;
}

@end

@implementation GmpObjC


- (instancetype) init {
    return [self initWithDouble:0.0 andPrecision:100];
}

- (instancetype) initWithDouble:(double) d andPrecision: (long) nBits {
    self = [super init];
    if(self != nil) {
        mpfr_init2 (mpfr, nBits);
        mpfr_set_d (mpfr, d, MPFR_RNDD);
    }
    return self;
}

- (void) setPrecisionTo:(long) nBits {
    mpfr_set_prec (mpfr, nBits);
}

- (void)dealloc
{
    mpfr_clear(mpfr);
}


- (void) π {
    mpfr_const_pi(mpfr, GMP_RNDD);
}
- (void) γ {
    mpfr_const_euler(mpfr, GMP_RNDD);
}
- (void) e {
    mpfr_t one;
    mpfr_init2 (one, mpfr_get_prec(mpfr));
    mpfr_set_d (one, 1.0, MPFR_RNDD);
    mpfr_exp(mpfr, one, GMP_RNDD);
    mpfr_clear(one);
}

- (void) add:(GmpObjC*) other {
    mpfr_add(mpfr, mpfr, other->mpfr, GMP_RNDD);
}

- (void) div:(GmpObjC*) other {
    mpfr_div(mpfr, mpfr, other->mpfr, GMP_RNDD);
}

- (void) sub:(GmpObjC*) other {
    mpfr_sub(mpfr, mpfr, other->mpfr, GMP_RNDD);
}

- (void) mul:(GmpObjC*) other {
    mpfr_mul(mpfr, mpfr, other->mpfr, GMP_RNDD);
}

- (void) changeSign {
    mpfr_neg(mpfr, mpfr, GMP_RNDD);
}

- (void) sqrt {
    mpfr_sqrt(mpfr, mpfr, GMP_RNDD);
}
- (void) sqrt3 {
    mpfr_cbrt(mpfr, mpfr, GMP_RNDD);
}
- (void) rez {
    mpfr_ui_div(mpfr, 1, mpfr, GMP_RNDD);
}
- (void) fac {
    long n = mpfr_get_si(mpfr, GMP_RNDD);
    if (n >= 0) {
        mpfr_fac_ui(mpfr, n, GMP_RNDD);
    } else {
        mpfr_set_d(mpfr, 0.0, GMP_RNDD);
    }
}
- (void) ln {
    mpfr_log(mpfr, mpfr, GMP_RNDD);
}
- (void) log10 {
    mpfr_log10(mpfr, mpfr, GMP_RNDD);
}
- (void) sin {
    mpfr_sin(mpfr, mpfr, GMP_RNDD);
}
- (void) cos {
    mpfr_cos(mpfr, mpfr, GMP_RNDD);
}
- (void) tan {
    mpfr_tan(mpfr, mpfr, GMP_RNDD);
}
- (void) pow_x_2 {
    mpfr_sqr(mpfr, mpfr, GMP_RNDD);
}
- (void) pow_x_3 {
    mpfr_pow_ui(mpfr, mpfr, 3, GMP_RNDD);
}
- (void) pow_e_x {
    mpfr_exp(mpfr, mpfr, GMP_RNDD);
}
- (void) pow_10_x {
    mpfr_exp10(mpfr, mpfr, GMP_RNDD);
}
- (void) pow_x_y:(GmpObjC*) exponent {
    mpfr_pow(mpfr, mpfr, exponent->mpfr, GMP_RNDD);
}

- (bool) isNull {
    return mpfr_cmp_d(mpfr, 0.0) == 0;
}

- (bool) isNegative {
    return mpfr_cmp_d(mpfr, 0.0) < 0;
}


- (NSString*) toString {
    NSString* ret;
    
    if (mpfr_nan_p(mpfr)) {
        return @"Not a Number";
    }
    if (mpfr_inf_p(mpfr)) {
        return @"Infinity";
    }

    // set negative 0 to 0
    if (mpfr_zero_p(mpfr)) {
        return @"0";
    }

    // special case double
    if (mpfr_get_prec(mpfr) == 53) {
        ret = [NSString stringWithFormat:@"%.17g", mpfr_get_d(mpfr, GMP_RNDD)];
        return ret;
    }

    // higher precision
    int significantBytesEstimate = (int)round(0.3 * mpfr_get_prec(mpfr));
    mpfr_exp_t expptr;
    char c[significantBytesEstimate+10];
    mpfr_get_str(c, &expptr, 10, significantBytesEstimate, mpfr, GMP_RNDD);
    NSMutableString *s1 = [[NSString stringWithCString:c encoding:[NSString defaultCStringEncoding]] mutableCopy];
    while ([s1 length] < 2) s1 = [[s1 stringByAppendingString:@"0"] mutableCopy];
    if ([s1 hasPrefix:@"-"]) {
        [s1 insertString:@"." atIndex:2];
    } else {
        [s1 insertString:@"." atIndex:1];
    }
    ret = [NSString stringWithFormat:@"%@ E%02ld", s1, expptr-1];
    return ret;
}

@end

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
    long status; // not used a t the moment
}

@end

@implementation GmpObjC


- (instancetype) init {
    return [self initWithDouble:0.0 andPrecision:100];
}

- (instancetype) initWithDouble:(double) d andPrecision: (long) nBits {
    self = [super init];
    if(self != nil) {
        status = 0;
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
    mpfr_const_pi(mpfr, MPFR_RNDN);
    status = 0;
}
- (void) γ {
    mpfr_const_euler(mpfr, MPFR_RNDN);
    status = 0;
}
- (void) e {
    mpfr_t one;
    mpfr_init2 (one, mpfr_get_prec(mpfr));
    mpfr_set_d (one, 1.0, MPFR_RNDD);
    mpfr_set_d (mpfr, 1.0, MPFR_RNDD);
    mpfr_exp(mpfr, one, MPFR_RNDN); // Strangely, this returns a status of -1
    mpfr_clear(one);
    status = 0;
}

- (void) add:(GmpObjC*) other {
    status = mpfr_add(mpfr, mpfr, other->mpfr, MPFR_RNDN);
}

- (void) div:(GmpObjC*) other {
    status = mpfr_div(mpfr, mpfr, other->mpfr, MPFR_RNDN);
}

- (void) sub:(GmpObjC*) other {
    status = mpfr_sub(mpfr, mpfr, other->mpfr, MPFR_RNDN);
}

- (void) mul:(GmpObjC*) other {
    status = mpfr_mul(mpfr, mpfr, other->mpfr, MPFR_RNDN);
}

- (void) changeSign {
   status =  mpfr_neg(mpfr, mpfr, MPFR_RNDN);
}

- (void) sqrt {
    status = mpfr_sqrt(mpfr, mpfr, MPFR_RNDN);
}
- (void) sqrt3 {
    status = mpfr_cbrt(mpfr, mpfr, MPFR_RNDN);
}
- (void) rez {
    status = mpfr_ui_div(mpfr, 1, mpfr, MPFR_RNDN);
}
- (void) fac {
    long n = mpfr_get_si(mpfr, MPFR_RNDN);
    if (n >= 0) {
        status = mpfr_fac_ui(mpfr, n, MPFR_RNDN);
    } else {
        status = mpfr_set_d(mpfr, 0.0, MPFR_RNDN);
    }
}
- (void) ln {
    status = mpfr_log(mpfr, mpfr, MPFR_RNDN);
}
- (void) log10 {
    status = mpfr_log10(mpfr, mpfr, MPFR_RNDN);
}
- (void) sin {
    status = mpfr_sin(mpfr, mpfr, MPFR_RNDN);
}
- (void) cos {
    status = mpfr_cos(mpfr, mpfr, MPFR_RNDN);
}
- (void) tan {
    status = mpfr_tan(mpfr, mpfr, MPFR_RNDN);
}
- (void) pow_x_2 {
    status = mpfr_sqr(mpfr, mpfr, MPFR_RNDN);
}
- (void) pow_x_3 {
    status = mpfr_pow_ui(mpfr, mpfr, 3, MPFR_RNDN);
}
- (void) pow_e_x {
    status = mpfr_exp(mpfr, mpfr, MPFR_RNDN);
}
- (void) pow_10_x {
    status = mpfr_exp10(mpfr, mpfr, MPFR_RNDN);
}
- (void) pow_x_y:(GmpObjC*) exponent {
    status = mpfr_pow(mpfr, mpfr, exponent->mpfr, MPFR_RNDN);
}
- (void) x_double_up_arrow_y:(GmpObjC*) exponent {
    mpfr_t left;
    mpfr_init2 (left, mpfr_get_prec(mpfr));
    mpfr_set(left, mpfr, MPFR_RNDN);

    long counter = mpfr_get_ui(exponent->mpfr, MPFR_RNDN) - 1;
    for (long i = 0; i < counter; i++) {
         mpfr_pow(mpfr, left, mpfr, MPFR_RNDN);
    }
    mpfr_clear(left);
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

    // special case: no precision loss when converted to double?
    double asDouble = mpfr_get_d(mpfr, MPFR_RNDN);
    mpfr_t test;
    mpfr_init2 (test, mpfr_get_prec(mpfr));
    mpfr_set_d (test, asDouble, MPFR_RNDD);
    if (mpfr_cmp(mpfr, test) == 0) {
        ret = [NSString stringWithFormat:@"%.17g", mpfr_get_d(mpfr, MPFR_RNDN)];
        mpfr_clear(test);
    } else {
        mpfr_clear(test);
        
        // higher precision
        int significantBytesEstimate = (int)round(0.3 * mpfr_get_prec(mpfr));
        mpfr_exp_t expptr;
        char c[significantBytesEstimate+10];
        mpfr_get_str(c, &expptr, 10, significantBytesEstimate, mpfr, MPFR_RNDN);
        NSMutableString *s1 = [[NSString stringWithCString:c encoding:[NSString defaultCStringEncoding]] mutableCopy];
        
        // cut tailing zeros
        NSInteger positionOfLastNonNullCharacter = -1;
        BOOL done = NO;
        for (NSUInteger pos = s1.length-1; pos > 0; pos--) {
            if (!done) {
                NSString * newString = [s1 substringWithRange:NSMakeRange(pos, 1)];
                if ([newString  isEqualToString:@"0"]) {
                    positionOfLastNonNullCharacter = pos;
                } else {
                    done = YES;
                }
            }
        }
        NSMutableString* s2;
        if (positionOfLastNonNullCharacter > 0) {
            s2 = [[s1 substringWithRange:NSMakeRange(0, positionOfLastNonNullCharacter)] mutableCopy];
        } else {
            // no tailing zeroes
            s2 = s1;
        }
        
        // make sure, the string is at least 2 characters long
        while ([s2 length] < 2) s2 = [[s2 stringByAppendingString:@"0"] mutableCopy];
        
        
        if ([s2 hasPrefix:@"-"]) {
            [s2 insertString:@"." atIndex:2];
        } else {
            [s2 insertString:@"." atIndex:1];
        }
        ret = [NSString stringWithFormat:@"%@ E%02ld", s2, expptr-1];
    }
    return ret;
}

@end

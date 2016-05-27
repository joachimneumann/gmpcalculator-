//
//  GmpObjC.h
//  Calculator
//
//  Created by Joachim Neumann on 23/05/16.
//  Copyright © 2016 VISAMED IT. All rights reserved.
//

#ifndef GmpObjC_h
#define GmpObjC_h

#import <Foundation/Foundation.h>

@interface GmpObjC : NSObject

- (instancetype) init;
- (instancetype) initWithDouble:(double) d andPrecision:(long) nBits;
- (void) setPrecisionTo:(long) nBits;

- (void) π;
- (void) e;
- (void) γ;
- (void) add:(GmpObjC*) other;
- (void) div:(GmpObjC*) other;
- (void) sub:(GmpObjC*) other;
- (void) mul:(GmpObjC*) other;
- (void) pow_x_y:(GmpObjC*) other;
- (void) x_double_up_arrow_y:(GmpObjC*) other;
- (void) sqrt;
- (void) sqrt3;
- (void) rez;
- (void) fac;
- (void) ln;
- (void) log10;
- (void) sin;
- (void) cos;
- (void) tan;
- (void) pow_x_2;
- (void) pow_x_3;
- (void) pow_e_x;
- (void) pow_10_x;
- (void) changeSign;
- (bool) isNull;
- (bool) isNegative;
- (NSString*) toString;


@end

#endif /* GmpObjC_h */

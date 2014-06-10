//
//  BITEUntilEnumerator.h
//  Bite
//
//  Created by Brian Nickel on 6/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEEnumerator.h"

@interface BITEUntilEnumerator : BITEEnumerator
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator test:(BOOL(^)(id))test;
@end

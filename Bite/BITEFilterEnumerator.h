//
//  BITEFilterEnumerator.h
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEEnumerator.h"

@interface BITEFilterEnumerator : BITEEnumerator
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator filter:(BOOL(^)(id))filter;
@end

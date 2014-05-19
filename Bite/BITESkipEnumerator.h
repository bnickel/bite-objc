//
//  BITESkipEnumerator.h
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEEnumerator.h"

@interface BITESkipEnumerator : BITEEnumerator

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator count:(NSUInteger)count;

@end

//
//  BITEMapEnumerator.h
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEEnumerator.h"

@interface BITEMapEnumerator : BITEEnumerator
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator mappingFunction:(id(^)(id))mappingFunction;
@end

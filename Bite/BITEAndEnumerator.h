//
//  BITEAndEnumerator.h
//  Bite
//
//  Created by Brian Nickel on 6/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEEnumerator.h"

@interface BITEAndEnumerator : BITEEnumerator

- (instancetype)initWithFirstEnumerator:(id<NSFastEnumeration>)firstEnumerator secondEnumerator:(id<NSFastEnumeration>)secondEnumerator;

@end

//
//  BITEGrouping.m
//  Bite
//
//  Created by Brian Nickel on 5/20/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEGrouping.h"

@implementation BITEGrouping

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator
{
    return [self initWithEnumerator:enumerator key:nil choke:0];
}

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator choke:(NSUInteger)choke
{
    return [self initWithEnumerator:enumerator key:nil choke:choke];
}

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator key:(id<NSCopying>)key
{
    return [self initWithEnumerator:enumerator key:key choke:0];
}

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator key:(id<NSCopying>)key choke:(NSUInteger)choke
{
    self = [super initWithEnumerator:enumerator choke:choke];
    if (self) {
        _key = [key copyWithZone:nil];
    }
    return self;
}

@end

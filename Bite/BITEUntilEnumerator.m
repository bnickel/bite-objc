//
//  BITEUntilEnumerator.m
//  Bite
//
//  Created by Brian Nickel on 6/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEUntilEnumerator.h"

@interface BITEUntilEnumerator ()
@property (nonatomic, copy) BOOL(^test)(id);
@end


@implementation BITEUntilEnumerator

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator test:(BOOL (^)(id))test
{
    self = [super initWithEnumerator:enumerator];
    if (self) {
        _test = test;
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    if (state->state == NSNotFound) {
        return 0;
    }
    
    NSUInteger clampedCount = [super countByEnumeratingWithState:state objects:buffer count:len];
    for (NSUInteger i = 0; i < clampedCount; i ++) {
        if (self.test(state->itemsPtr[i])) {
            state->state = NSNotFound;
            return i;
        }
    }
    return clampedCount;
}

@end

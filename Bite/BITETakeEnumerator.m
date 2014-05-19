//
//  BITETakeEnumerator.m
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITETakeEnumerator.h"

@interface BITETakeEnumerator ()
@property (nonatomic, readonly) NSInteger count;
@end

@implementation BITETakeEnumerator

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator count:(NSUInteger)count
{
    self = [super initWithEnumerator:enumerator];
    if (self) {
        _count = count;
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    if (state->state >= self.count) {
        return 0;
    }
    
    NSFastEnumerationState *wrappedState = [self wrappedStateForState:state];
    
    NSUInteger maxToTake = self.count - state->state;
    
    NSUInteger numberTaken = [self.wrappedEnumerator countByEnumeratingWithState:wrappedState objects:buffer count:MIN(maxToTake, len)];
    
    state->state += numberTaken;
    state->itemsPtr = wrappedState->itemsPtr;
    state->mutationsPtr = wrappedState->mutationsPtr;
    
    return MIN(numberTaken, maxToTake);
}

@end

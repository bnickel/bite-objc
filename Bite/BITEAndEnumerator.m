//
//  BITEAndEnumerator.m
//  Bite
//
//  Created by Brian Nickel on 6/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEAndEnumerator.h"

typedef NS_ENUM(NSInteger, Extra3State) {
    Extra3StateEnumeratingFirst = 0,
    Extra3StateEnumeratingSecond
};

@interface BITEAndEnumerator ()
@property (nonatomic, readonly) id<NSFastEnumeration>secondWrappedEnumerator;
@end

@implementation BITEAndEnumerator

- (instancetype)initWithFirstEnumerator:(id<NSFastEnumeration>)firstEnumerator secondEnumerator:(id<NSFastEnumeration>)secondEnumerator
{
    self = [super initWithEnumerator:firstEnumerator];
    if (self) {
        _secondWrappedEnumerator = secondEnumerator;
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    if (state->state == 0) {
        state->extra[3] = Extra3StateEnumeratingFirst;
    }
    
    if (state->extra[3] == Extra3StateEnumeratingFirst) {
        NSUInteger count = [super countByEnumeratingWithState:state objects:buffer count:len];
        if (count > 0) {
            return count;
        }
        
        state->state = 0;
        state->extra[3] = Extra3StateEnumeratingSecond;
    }
    
    {
        NSFastEnumerationState *secondState = [self wrappedStateForState:state];
        NSUInteger count = [self.secondWrappedEnumerator countByEnumeratingWithState:secondState objects:buffer count:len];
        state->itemsPtr = secondState->itemsPtr;
        state->state = 2;
        return count;
    }
}

@end

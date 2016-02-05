//
//  BITEEnumerateEnumerator.m
//  Bite
//
//  Created by Brian Nickel on 2/5/16.
//  Copyright © 2016 Brian Nickel. All rights reserved.
//

#import "BITEEnumerateEnumerator.h"

@implementation BITEEnumerateEnumerator

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    if (state->state == 0) {
        state->extra[3] = 0;
    }
    
    NSUInteger clampedCount = [super countByEnumeratingWithState:state objects:buffer count:len];
    
    for (NSUInteger i = 0; i < clampedCount; i ++) {
        unsigned long index = state->extra[3] ++;
        __autoreleasing id nextItemWithLongLifespan = BITE_TUPLE(@(index), state->itemsPtr[i]);
        buffer[i] = nextItemWithLongLifespan;
    }
    state->itemsPtr = buffer;
    
    return clampedCount;
}

@end

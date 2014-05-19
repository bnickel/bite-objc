//
//  BITEFilterEnumerator.m
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEFilterEnumerator.h"

@interface BITEFilterEnumerator ()
@property (nonatomic, copy) BOOL(^filter)(id);
@end

@implementation BITEFilterEnumerator

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator filter:(BOOL (^)(id))filter
{
    self = [super initWithEnumerator:enumerator];
    if (self) {
        _filter = filter;
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    NSUInteger matched = 0;
    NSUInteger clampedCount;
    
    do {
        clampedCount = [super countByEnumeratingWithState:state objects:buffer count:len];
        for (NSUInteger i = 0; i < clampedCount; i ++) {
            if (self.filter(state->itemsPtr[i])) {
                buffer[matched ++] = state->itemsPtr[i];
            }
        }
    } while (matched == 0 && clampedCount != 0);
    
    state->itemsPtr = buffer;
    
    return matched;
}


@end

//
//  BITESkipEnumerator.m
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITESkipEnumerator.h"

@interface BITESkipEnumerator ()
@property (nonatomic, readonly) NSUInteger count;
@end

@implementation BITESkipEnumerator

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
    if (state->state == 0) {
        NSUInteger totalCount = 0;
        while (totalCount < self.count) {
            NSUInteger count = [super countByEnumeratingWithState:state objects:buffer count:MIN(len, self.count - totalCount)];
            if (count == 0) {
                return 0;
            }
            totalCount += count;
        }
    }
    
    return [super countByEnumeratingWithState:state objects:buffer count:len];
}

@end

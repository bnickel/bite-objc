//
//  BITEMapEnumerator.m
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEMapEnumerator.h"

@interface BITEMapEnumerator ()
@property (nonatomic, copy) id(^mappingFunction)(id);
@end

@implementation BITEMapEnumerator
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator mappingFunction:(id(^)(id))mappingFunction
{
    self = [super initWithEnumerator:enumerator];
    if (self) {
        _mappingFunction = mappingFunction;
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    NSUInteger clampedCount = [super countByEnumeratingWithState:state objects:buffer count:len];
    
    for (NSUInteger i = 0; i < clampedCount; i ++) {
        __autoreleasing id whatSpockSaidToMcCoyAtTheEndOfWrathOfKhan = self.mappingFunction(state->itemsPtr[i]);
        buffer[i] = whatSpockSaidToMcCoyAtTheEndOfWrathOfKhan;
    }
    state->itemsPtr = buffer;
    
    return clampedCount;
}

@end

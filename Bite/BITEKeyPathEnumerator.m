//
//  BITEKeyPathEnumerator.m
//  Bite
//
//  Created by Brian Nickel on 7/29/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEKeyPathEnumerator.h"

@interface BITEKeyPathEnumerator ()
@property (nonatomic, readonly, strong) id object;
@property (nonatomic, readonly, copy) NSString *keyPath;
@property (nonatomic, assign) SEL selector;
@end

@implementation BITEKeyPathEnumerator

- (instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath
{
    self = [super init];
    if (self) {
        _object = object;
        _keyPath = [keyPath copy];
    }
    return self;
}

- (instancetype)initWithObject:(id)object selector:(SEL)selector
{
    self = [super init];
    if (self) {
        _object = object;
        _selector = selector;
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    if (state->state == 0) {
        state->state = 1;
        state->extra[0] = (unsigned long)self.object;
        state->mutationsPtr = &state->state;
    }
    
    state->itemsPtr = buffer;
    
    for (NSUInteger i = 0; i < len; i ++) {
        __unsafe_unretained id item = (__bridge id)((const void *)state->extra[0]);
        
        if (item == nil) {
            return i;
        }
        
        buffer[i] = item;
        __autoreleasing id nextItemWithLongLifespan;
        
        if (self.keyPath) {
            nextItemWithLongLifespan = [item valueForKeyPath:self.keyPath];
        } else {
            id(*func)(id, SEL) = (id(*)(id, SEL))[item methodForSelector:self.selector];
            nextItemWithLongLifespan = func(item, self.selector);
        }
        
        state->extra[0] = (unsigned long)nextItemWithLongLifespan;
    }
    
    return len;
}

@end

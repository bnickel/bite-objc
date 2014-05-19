//
//  NSPrimeEnumerator.m
//  Bite
//
//  Created by Brian Nickel on 5/19/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "PrimeEnumerator.h"

@interface PrimeEnumerator ()
@property (nonatomic, strong) NSMutableArray *primes;
@end

@implementation PrimeEnumerator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _primes = [NSMutableArray arrayWithObject:@2];
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    if (state->state == 0) {
        state->extra[0] = 0;
        state->state = 1;
        state->mutationsPtr = &(state->state);
    }
    
    unsigned long index = state->extra[0];
    unsigned long lastKnownPrime = state->extra[1];
    
    for (NSUInteger i = 0; i < len; i ++) {
        
        if (index < self.primes.count) {
            lastKnownPrime = [(buffer[i] = self.primes[index++]) unsignedLongValue];
            continue;
        }
        
        while ([self isDivisibleByKnownPrimes:++lastKnownPrime]) ;
        
        NSNumber *primeNumber = @(lastKnownPrime);
        buffer[i] = primeNumber;
        [self.primes addObject:primeNumber];
        index = self.primes.count;
    }
    
    state->extra[0] = index;
    state->extra[1] = lastKnownPrime;
    state->itemsPtr = buffer;
    
    return len;
}

- (BOOL)isDivisibleByKnownPrimes:(unsigned long)number
{
    for (NSNumber *prime in self.primes) {
        if (number % [prime unsignedLongValue] == 0) {
            return YES;
        }
    }
    
    return NO;
}

- (NSArray *)knownPrimes
{
    return self.primes;
}

@end

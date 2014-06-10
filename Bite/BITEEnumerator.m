//
//  BITEEnumerator.m
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEEnumerator.h"
#import "BITETakeEnumerator.h"
#import "BITESkipEnumerator.h"
#import "BITEMapEnumerator.h"
#import "BITEFilterEnumerator.h"
#import "BITEUntilEnumerator.h"
#import "BITEAndEnumerator.h"
#import "BITEGrouping.h"

@interface BITEEnumerator ()
@property (nonatomic, readonly) NSMutableArray *wrappedStates;
@property (nonatomic, readonly) NSUInteger choke;
@end

@implementation BITEEnumerator

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator
{
    return [self initWithEnumerator:enumerator choke:0];
}

- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator choke:(NSUInteger)choke
{
    self = [super init];
    if (self) {
        _wrappedEnumerator = enumerator;
        _wrappedStates = [[NSMutableArray alloc] init];
        _choke = choke;
    }
    return self;
}

- (NSFastEnumerationState *)wrappedStateForState:(NSFastEnumerationState *)state
{
    NSMutableData *mutableData;
    if (state->state != 0) {
        mutableData = self.wrappedStates[state->extra[0]];
    } else {
        mutableData = [[NSMutableData alloc] initWithLength:sizeof(NSFastEnumerationState)];
        state->extra[0] = self.wrappedStates.count;
        [self.wrappedStates addObject:mutableData];
    }
    return (NSFastEnumerationState *)mutableData.mutableBytes;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    if (self.choke && self.choke < len) {
        len = self.choke;
    }
    
    NSFastEnumerationState *wrappedState = [self wrappedStateForState:state];
    
    if (state->state == 0) {
        state->state = 1;
        state->extra[1] = 0;
        state->extra[2] = 0;
    }
    
    NSUInteger currentIndex = state->extra[1];
    NSUInteger savedCount = state->extra[2];
    
    if (currentIndex == savedCount) {
        currentIndex = 0;
        savedCount = [self.wrappedEnumerator countByEnumeratingWithState:wrappedState objects:buffer count:len];
        state->extra[2] = savedCount;
    }
    
    
    NSInteger takenCount = MIN(len, savedCount - currentIndex);
    
    state->extra[1] = currentIndex + takenCount;
    state->itemsPtr = wrappedState->itemsPtr + currentIndex;
    state->mutationsPtr = wrappedState->mutationsPtr;
    
    return takenCount;
}

- (NSUInteger)count
{
    NSUInteger count = 0;
    for (__unused id obj in self) {
        count += 1;
    }
    return count;
}

- (NSArray *)array
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (id obj in self) {
        [array addObject:obj];
    }
    return [array copy];
}

- (NSSet *)set
{
    NSMutableSet *set = [[NSMutableSet alloc] init];
    for (id obj in self) {
        [set addObject:obj];
    }
    return [set copy];
}

- (NSDictionary *)dictionaryWithKeyPath:(NSString *)keyPath valuePath:(NSString *)valuePath
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    for (id obj in self) {
        [dictionary setObject:[obj valueForKeyPath:valuePath] forKey:[obj valueForKeyPath:keyPath]];
    }
    return [dictionary copy];
}

- (NSDictionary *)dictionaryWithPairs
{
    return [self dictionaryWithKeyPath:@"_1" valuePath:@"_2"];
}

- (NSString *)joinedByString:(NSString *)separator
{
    NSMutableString *string = [[NSMutableString alloc] init];
    BOOL first = YES;
    
    for (id obj in self) {
        if (first) {
            first = NO;
        } else {
            [string appendString:separator];
        }
        [string appendString:[obj description] ?: @"(null)"];
    }
    return [string copy];
}

- (BOOL)any:(BOOL (^)(id))test
{
    NSParameterAssert(test);
    for (id obj in [self choke:1]) {
        if (test(obj)) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)anyMatchPredicate:(NSPredicate *)predicate
{
    return [self any:^BOOL(id obj) {
        return [predicate evaluateWithObject:obj];
    }];
}

- (BOOL)anyMatchFormat:(NSString *)predicateFormat, ...
{
    va_list arguments;
    va_start(arguments, predicateFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:arguments];
    va_end(arguments);
    return [self anyMatchPredicate:predicate];
}

- (BOOL)all:(BOOL (^)(id))test
{
    NSParameterAssert(test);
    for (id obj in [self choke:1]) {
        if (!test(obj)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)allMatchPredicate:(NSPredicate *)predicate
{
    return [self all:^BOOL(id obj) {
        return [predicate evaluateWithObject:obj];
    }];
}

- (BOOL)allMatchFormat:(NSString *)predicateFormat, ...
{
    va_list arguments;
    va_start(arguments, predicateFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:arguments];
    va_end(arguments);
    return [self allMatchPredicate:predicate];
}

- (id)first:(out BOOL *)exists
{
    for (id obj in [self choke:1]) {
        if (exists) {
            *exists = YES;
        }
        return obj;
    }
    
    if (exists) {
        *exists = NO;
    }
    return nil;
}

- (id)last:(out BOOL *)exists
{
    BOOL internalExists = NO;
    id lastObject = nil;
    for (id obj in self) {
        internalExists = YES;
        lastObject = obj;
    }
    
    if (exists) {
        *exists = internalExists;
    }
    
    return lastObject;
}

- (id)foldLeft:(id)initial func:(id (^)(id, id))func
{
    id accumulator = initial;
    for (id obj in self) {
        accumulator = func(accumulator, obj);
    }
    return accumulator;
}

- (id)foldRight:(id)initial func:(id (^)(id, id))func
{
    return [BITE(self.array.reverseObjectEnumerator) foldLeft:initial func:^id(id acc, id obj) {
        return func(obj, acc);
    }];
}

- (id)reduceLeft:(id (^)(id, id))func
{
    BOOL first = true;
    id accumulator = nil;
    for (id obj in self) {
        if (first) {
            first = NO;
            accumulator = obj;
        } else {
            accumulator = func(accumulator, obj);
        }
    }
    return accumulator;
}

- (id)reduceRight:(id (^)(id, id))func
{
    return [BITE(self.array.reverseObjectEnumerator) reduceLeft:^id(id acc, id obj) {
        return func(obj, acc);
    }];
}

- (BITEEnumerator *)take:(NSUInteger)count
{
    return [[BITETakeEnumerator alloc] initWithEnumerator:self count:count];
}

- (BITEEnumerator *)skip:(NSUInteger)count
{
    return [[BITESkipEnumerator alloc] initWithEnumerator:self count:count];
}

- (BITEEnumerator *)map:(id (^)(id))mappingFunction
{
    return [[BITEMapEnumerator alloc] initWithEnumerator:self mappingFunction:mappingFunction];
}

- (BITEEnumerator *)mapWithExpression:(NSExpression *)expression
{
    return [self map:^id(id obj) {
        return [expression expressionValueWithObject:obj context:nil];
    }];
}

- (BITEEnumerator *)mapWithFormat:(NSString *)expressionFormat, ...
{
    va_list arguments;
    va_start(arguments, expressionFormat);
    NSExpression *expression = [NSExpression expressionWithFormat:expressionFormat arguments:arguments];
    va_end(arguments);
    return [self mapWithExpression:expression];
}

- (BITEEnumerator *)mapWithKeyPath:(NSString *)keyPath
{
    return [self mapWithExpression:[NSExpression expressionForKeyPath:keyPath]];
}

- (BITEEnumerator *)filter:(BOOL (^)(id))filter
{
    return [[BITEFilterEnumerator alloc] initWithEnumerator:self filter:filter];
}

- (BITEEnumerator *)filterWithPredicate:(NSPredicate *)predicate
{
    return [self filter:^BOOL(id obj) {
        return [predicate evaluateWithObject:obj];
    }];
}

- (BITEEnumerator *)filterWithFormat:(NSString *)predicateFormat, ...
{
    va_list arguments;
    va_start(arguments, predicateFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:arguments];
    va_end(arguments);
    return [self filterWithPredicate:predicate];
}

- (BITEEnumerator *)choke:(NSUInteger)choke
{
    return [[BITEEnumerator alloc] initWithEnumerator:self choke:choke];
}

- (BITEEnumerator *)except:(id)obj
{
    return [self filter:^BOOL(id obj2) {
        return obj != obj2 && ![obj isEqual:obj2];
    }];
}

- (BITEEnumerator *)and:(id<NSFastEnumeration>)enumerator
{
    return [[BITEAndEnumerator alloc] initWithFirstEnumerator:self secondEnumerator:enumerator];
}

- (BITEEnumerator *)andObject:(id)obj
{
    return [self and:@[obj]];
}

- (BITEEnumerator *)until:(BOOL (^)(id))test
{
    return [[BITEUntilEnumerator alloc] initWithEnumerator:self test:test];
}

- (BITEEnumerator *)untilWithPredicate:(NSPredicate *)predicate
{
    return [self until:^BOOL(id obj) {
        return [predicate evaluateWithObject:obj];
    }];
}

- (BITEEnumerator *)untilWithFormat:(NSString *)predicateFormat, ...
{
    va_list arguments;
    va_start(arguments, predicateFormat);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat arguments:arguments];
    va_end(arguments);
    return [self untilWithPredicate:predicate];
}

- (BITEEnumerator *)groupBy:(id<NSCopying> (^)(id))func
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (id obj in self) {
        id<NSCopying> key = func(obj);
        NSMutableArray *array = dictionary[key] ?: ({
            NSMutableArray *array = [NSMutableArray array];
            dictionary[key] = array;
            array;
        });
        [array addObject:obj];
    }
    
    return [BITE(dictionary) map:^id(id<NSCopying> obj) {
        return [[BITEGrouping alloc] initWithEnumerator:dictionary[obj] key:obj];
    }];
}

- (BITEEnumerator *)groupByKeyPath:(NSString *)keyPath
{
    return [self groupBy:^id<NSCopying>(id obj) {
        return [obj valueForKeyPath:keyPath];
    }];
}

@end

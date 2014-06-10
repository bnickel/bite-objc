//
//  BITEEnumerator.h
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BITEEnumerator : NSObject<NSFastEnumeration>

@property (nonatomic, readonly) id<NSFastEnumeration>wrappedEnumerator;
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator;
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator choke:(NSUInteger)choke;
- (NSFastEnumerationState *)wrappedStateForState:(NSFastEnumerationState *)state;

#pragma mark Transforms

- (BITEEnumerator *)take:(NSUInteger)count;
- (BITEEnumerator *)skip:(NSUInteger)count;

- (BITEEnumerator *)map:(id (^)(id obj))mappingFunction;
- (BITEEnumerator *)mapWithExpression:(NSExpression *)expression;
- (BITEEnumerator *)mapWithFormat:(NSString *)expressionFormat, ...;
- (BITEEnumerator *)mapWithKeyPath:(NSString *)keyPath;

- (BITEEnumerator *)filter:(BOOL (^)(id obj))test;
- (BITEEnumerator *)filterWithPredicate:(NSPredicate *)predicate;
- (BITEEnumerator *)filterWithFormat:(NSString *)predicateFormat, ...;
- (BITEEnumerator *)choke:(NSUInteger)choke;
- (BITEEnumerator *)except:(id)obj;

- (BITEEnumerator *)groupBy:(id<NSCopying> (^)(id obj))func;
- (BITEEnumerator *)groupByKeyPath:(NSString *)keyPath;

#pragma mark Evaluation

- (NSUInteger)count;
- (NSArray *)array;
- (NSSet *)set;
- (NSDictionary *)dictionaryWithKeyPath:(NSString *)keyPath valuePath:(NSString *)valuePath;
- (NSDictionary *)dictionaryWithPairs;
- (NSString *)joinedByString:(NSString *)separator;
- (BOOL)any:(BOOL (^)(id obj))test;
- (BOOL)anyMatchPredicate:(NSPredicate *)predicate;
- (BOOL)anyMatchFormat:(NSString *)predicateFormat, ...;
- (BOOL)all:(BOOL (^)(id obj))test;
- (BOOL)allMatchPredicate:(NSPredicate *)predicate;
- (BOOL)allMatchFormat:(NSString *)predicateFormat, ...;
- (id)first:(out BOOL *)exists;

@end

__attribute__((overloadable)) NS_INLINE BITEEnumerator *BITE(id<NSFastEnumeration> enumerator) {
    return [[BITEEnumerator alloc] initWithEnumerator:enumerator];
}

__attribute__((overloadable)) NS_INLINE BITEEnumerator *BITE(id<NSFastEnumeration> enumerator, NSUInteger choke) {
    return [[BITEEnumerator alloc] initWithEnumerator:enumerator choke:choke];
}

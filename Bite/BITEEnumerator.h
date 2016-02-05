//
//  BITEEnumerator.h
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/10/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BITEGrouping<ObjectType>;
@class BITETuple<T1, T2, T3, T4, T5, T6>;

@interface BITEEnumerator<ObjectType> : NSObject<NSFastEnumeration>

@property (nonatomic, readonly) id<NSFastEnumeration>wrappedEnumerator;
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator;
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator choke:(NSUInteger)choke;
- (NSFastEnumerationState *)wrappedStateForState:(NSFastEnumerationState *)state;
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len;

#pragma mark Transforms

- (BITEEnumerator<ObjectType> *)take:(NSUInteger)count;
- (BITEEnumerator<ObjectType> *)skip:(NSUInteger)count;

- (BITEEnumerator *)map:(id (^)(ObjectType obj))mappingFunction;
- (BITEEnumerator *)mapWithExpression:(NSExpression *)expression;
- (BITEEnumerator *)mapWithFormat:(NSString *)expressionFormat, ...;
- (BITEEnumerator *)mapWithKeyPath:(NSString *)keyPath;

- (BITEEnumerator<BITETuple<NSNumber *, id, id, id, id, id> *> *)enumerate; // Wraps items in a tuple (index, item)

- (BITEEnumerator<ObjectType> *)filter:(BOOL (^)(ObjectType obj))test;
- (BITEEnumerator<ObjectType> *)filterWithPredicate:(NSPredicate *)predicate;
- (BITEEnumerator<ObjectType> *)filterWithFormat:(NSString *)predicateFormat, ...;
- (BITEEnumerator<ObjectType> *)except:(ObjectType)obj;

- (BITEEnumerator *)and:(id<NSFastEnumeration>)enumerator;
- (BITEEnumerator<ObjectType> *)andObject:(ObjectType)obj;

- (BITEEnumerator<ObjectType> *)until:(BOOL (^)(ObjectType obj))test;
- (BITEEnumerator<ObjectType> *)untilWithPredicate:(NSPredicate *)predicate;
- (BITEEnumerator<ObjectType> *)untilWithFormat:(NSString *)predicateFormat, ...;

- (BITEEnumerator<BITEGrouping<ObjectType> *> *)groupBy:(id<NSCopying> (^)(id obj))func;
- (BITEEnumerator<BITEGrouping<ObjectType> *> *)groupByKeyPath:(NSString *)keyPath;

- (BITEEnumerator<ObjectType> *)choke:(NSUInteger)choke;

#pragma mark Evaluation

- (NSUInteger)count;
- (NSArray<ObjectType> *)array;
- (NSSet<ObjectType> *)set;
- (NSDictionary *)dictionaryWithKeyPath:(NSString *)keyPath valuePath:(NSString *)valuePath;
- (NSDictionary *)dictionaryWithPairs;
- (NSString *)joinedByString:(NSString *)separator;

- (BOOL)any:(BOOL (^)(ObjectType obj))test;
- (BOOL)anyMatchPredicate:(NSPredicate *)predicate;
- (BOOL)anyMatchFormat:(NSString *)predicateFormat, ...;

- (BOOL)all:(BOOL (^)(ObjectType obj))test;
- (BOOL)allMatchPredicate:(NSPredicate *)predicate;
- (BOOL)allMatchFormat:(NSString *)predicateFormat, ...;

- (ObjectType)first:(out BOOL *)exists;
- (ObjectType)last:(out BOOL *)exists;

- (id)foldLeft:(id)initial func:(id (^)(id acc, ObjectType obj))func;
- (id)foldRight:(id)initial func:(id (^)(ObjectType obj, id acc))func;

- (id)reduceLeft:(id (^)(id acc, ObjectType obj))func;
- (id)reduceRight:(id (^)(ObjectType obj, id acc))func;

@end

__attribute__((overloadable)) NS_INLINE BITEEnumerator *BITE(id<NSFastEnumeration> enumerator) {
    return [[BITEEnumerator alloc] initWithEnumerator:enumerator];
}

__attribute__((overloadable)) NS_INLINE BITEEnumerator *BITE(id<NSFastEnumeration> enumerator, NSUInteger choke) {
    return [[BITEEnumerator alloc] initWithEnumerator:enumerator choke:choke];
}

#define BITE_AS(enumerator, kind) ((BITEEnumerator<kind *> *)BITE(enumerator))

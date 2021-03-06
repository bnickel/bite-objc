//
//  BiteTests.m
//  BiteTests
//
//  Created by Brian Nickel on 5/19/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Bite.h"
#import "PrimeEnumerator.h"
#import "LinkedList.h"

@interface BiteTests : XCTestCase
{
    PrimeEnumerator *primes;
    NSMutableArray<NSNumber *> *numbers;
    NSMutableArray<NSNumber *> *odd;
    NSMutableArray<NSNumber *> *even;
}

@end

@implementation BiteTests

- (void)setUp
{
    [super setUp];
    primes = [[PrimeEnumerator alloc] init];
    
    numbers = [NSMutableArray array];
    even = [NSMutableArray array];
    odd = [NSMutableArray array];
    
    for (NSUInteger i = 0; i < 100; i ++) {
        [numbers addObject:@(i)];
        if (i % 2 == 0) {
            [even addObject:@(i)];
        } else {
            [odd addObject:@(i)];
        }
    }
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Transforms

#pragma mark take:

- (void)testThatTakeLimitsTheAmountTaken
{
    XCTAssertEqual(10, [[[BITE(primes) take:10] array] count], @"Take should have limited the count.");
    XCTAssertEqual(50, [[[BITE(primes) take:50] array] count], @"Take should have limited the count.");
}

- (void)testThatTakeLimitsTheNumberOfIteratorExecutions
{
    NSArray *items;
    
    items = [[BITE(primes) take:10] array];
    XCTAssertEqual(items.count, primes.knownPrimes.count, @"The enumerator should have stopped after %lu calls.", (unsigned long)items.count);
    
    items = [[BITE(primes) take:19] array];
    XCTAssertEqual(items.count, primes.knownPrimes.count, @"The enumerator should have stopped after %lu calls.", (unsigned long)items.count);
}

#pragma mark skip:

- (void)testSkip
{
    NSArray *items = [[[BITE(primes) skip:15] take:5] array];
    XCTAssertEqual(20, primes.knownPrimes.count, @"Should have iterated over 20 elements.");
    XCTAssertEqualObjects(items, [primes.knownPrimes subarrayWithRange:NSMakeRange(15, 5)], @"Subarray should match.");
}

#pragma mark map*:

- (void)testMap
{
    NSArray *items = [[[BITE(primes) take:2] map:^id(id obj) {
        return [[NSString alloc] initWithFormat:@"%@ is prime", obj];
    }] array];
    NSArray *expected = @[@"2 is prime", @"3 is prime"];
    XCTAssertEqualObjects(expected, items, @"Should have been transformed and autoreleased.");
}

- (void)testMapWithExpression
{
    NSArray *items = [[[BITE(primes) take:3] mapWithExpression:[NSExpression expressionWithFormat:@"SELF ** 2"]] array];
    NSArray *expected = @[@4, @9, @25];
    XCTAssertEqualObjects(expected, items, @"Should have been transformed and autoreleased.");
}

- (void)testMapWithFormat
{
    NSArray *items = [[BITE(@[@"hello", @"world"]) mapWithFormat:@"uppercase:(SELF)"] array];
    NSArray *expected = @[@"HELLO", @"WORLD"];
    XCTAssertEqualObjects(expected, items, @"Should have been transformed and autoreleased.");
}

- (void)testMapWithFormatParameters
{
    NSArray *items = [[[BITE(primes) take:3] mapWithExpression:[NSExpression expressionWithFormat:@"SELF ** %@", @2]] array];
    NSArray *expected = @[@4, @9, @25];
    XCTAssertEqualObjects(expected, items, @"Should have been transformed and autoreleased.");
}

- (void)testMapWithKeyPath
{
    NSArray *items = [[BITE(@[@"hello", @"world"]) mapWithKeyPath:@"uppercaseString"] array];
    NSArray *expected = @[@"HELLO", @"WORLD"];
    XCTAssertEqualObjects(expected, items, @"Should have been transformed and autoreleased.");
}

#pragma mark filter*:

- (void)testFilter
{
    NSArray *items = [[BITE(numbers) filter:^BOOL(id obj) {
        return [obj integerValue] % 2 == 0;
    }] array];
    
    XCTAssertEqualObjects(items, even, @"Should be even.");
}

- (void)testFilterWithPredicate
{
    NSArray *items = [[BITE(numbers) filterWithPredicate:[NSPredicate predicateWithFormat:@"modulus:by:(SELF,2) == 0"]] array];
    XCTAssertEqualObjects(items, even, @"Should be even.");
}

- (void)testFilterWithFormat
{
    NSArray *items = [[BITE(numbers) filterWithFormat:@"modulus:by:(SELF,%@) == 0", @2] array];
    XCTAssertEqualObjects(items, even, @"Should be even.");
}

#pragma mark until*:

- (void)testUntil
{
    NSInteger lastPrimeLessThan100 = [[[BITE(primes) untilWithFormat:@"SELF > %@", @100] last:NULL] integerValue];
    XCTAssertEqual(lastPrimeLessThan100, 97, @"Should have stopped at 97.");
}

#pragma mark choke:

- (void)testChoke
{
    for (__unused id obj in [BITE(primes) choke:5]) {
        break;
    }
    
    XCTAssertEqual(5, primes.knownPrimes.count, @"Should have choked.");
}

- (void)testChokeParameter
{
    for (__unused id obj in BITE(primes, 5)) {
        break;
    }
    
    XCTAssertEqual(5, primes.knownPrimes.count, @"Should have choked.");
}

#pragma mark except:

- (void)testExcept
{
    NSArray *items = [[[[BITE(primes) except:@2] except:@5] take:2] array];
    XCTAssertEqualObjects(@3, items[0], @"Should have skipped 2.");
    XCTAssertEqualObjects(@7, items[1], @"Should have skipped 5.");
}

#pragma mark and:

- (void)testAnd
{
    NSSet *allNumbers = [[BITE(even) and:odd] set];
    XCTAssertEqualObjects(allNumbers, [NSSet setWithArray:numbers], "Should have combined sets.");
    
    NSArray *allNumbersNarrow = [[[[BITE(even, 1) and:BITE(odd, 1)] and:BITE(odd, 1)] and:BITE(even, 1)] array];
    NSArray *allNumbersByArray = [[[even arrayByAddingObjectsFromArray:odd] arrayByAddingObjectsFromArray:odd] arrayByAddingObjectsFromArray:even];
    XCTAssertEqualObjects(allNumbersNarrow, allNumbersByArray, "Should have combined arrays.");
}

- (void)testAndObject
{
    NSArray *items = [[BITE(@[@1,@2,@3,@4]) andObject:@5] array];
    NSArray *oneToFive = @[@1,@2,@3,@4,@5];
    XCTAssertEqualObjects(items, oneToFive, @"Should have appended.");
}

- (void)testAndNil
{
    XCTAssertEqualObjects([[BITE(nil) and:@[@1]] array], @[@1], @"Should have one element.");
    XCTAssertEqualObjects([[BITE(@[@1]) and:nil] array], @[@1], @"Should have one element.");
    XCTAssertEqualObjects([[BITE(nil) and:nil] array], @[], @"Should have zero elements.");
}


#pragma mark groupBy*:

- (void)testGroupBy
{
    NSDictionary *results = [[[BITE(numbers) groupBy:^id<NSCopying>(id obj) {
        return [obj integerValue] % 2 == 0 ? @"even" : @"odd";
    }] map:^id(BITEGrouping *group) {
        return BITE_TUPLE([group key], [group array]);
    }] dictionaryWithPairs];
    
    XCTAssertEqual(2, results.count, @"Should have two groups.");
    XCTAssertEqualObjects([even copy], results[@"even"], @"Should have grouped evens.");
    XCTAssertEqualObjects([odd copy], results[@"odd"], @"Should have grouped odds.");
}

#pragma mark - Evaluation

- (void)testExecutionDelay
{
    [[[BITE(primes) filter:^BOOL(id obj) {return [[obj description] hasSuffix:@"1"];}] skip:10000] take:10000];
    XCTAssertEqual(primes.knownPrimes.count, 1, @"Should not have iterated.");
}

- (void)testCount
{
    BITEEnumerator *evenEnum = [BITE(numbers) filterWithFormat:@"modulus:by:(SELF,2) == 0"];
    XCTAssertEqual(even.count, evenEnum.count, @"Should be the same.");
}

- (void)testSet
{
    NSSet *numbersSet = [BITE([even arrayByAddingObjectsFromArray:numbers]) set];
    XCTAssertEqual(numbers.count, numbersSet.count, @"Should not have duplicates.");
}

- (void)testDictionary
{
    NSDictionary *items = [BITE(@[@"hElLo", @"wOrld"]) dictionaryWithKeyPath:NSStringFromSelector(@selector(uppercaseString)) valuePath:NSStringFromSelector(@selector(lowercaseString))];
    XCTAssertEqualObjects(@"hello", items[@"HELLO"], @"Should have transformed on selectors.");
    XCTAssertEqualObjects(@"world", items[@"WORLD"], @"Should have transformed on selectors.");
}

- (void)testJoin
{
    XCTAssertEqualObjects([even componentsJoinedByString:@"-"], [BITE(even) joinedByString:@"-"], @"Should be equal.");
}

- (void)testThatAnyStopsAtTheFirstMatch
{
    NSNumber *largePrime = @97;
    BOOL hasLargePrime = [[BITE(primes) take:100] any:^BOOL(id obj) {
        return [obj isEqualToNumber:largePrime];
    }];
    XCTAssertTrue(hasLargePrime, @"That number should have been prime.");
    XCTAssertEqualObjects(largePrime, primes.knownPrimes.lastObject, @"Enumeration should have stopped at when found.");
}

- (void)testAnyWithPredicate
{
    BOOL thereAreBigPrimes =  [BITE(primes) anyMatchFormat:@"self > %@", @1000];
    XCTAssertTrue(thereAreBigPrimes, @"There should be big primes.");
}

- (void)testThatAllStopsAtTheFirstFailure
{
    BOOL thereAreNoPrimesGreaterThan99 = [BITE_AS(primes, NSNumber) all:^BOOL(NSNumber *obj) {
        return [obj integerValue] < 100;
    }];
    XCTAssertFalse(thereAreNoPrimesGreaterThan99, @"What about 101");
    XCTAssertEqualObjects(@101, primes.knownPrimes.lastObject, @"Enumeration should have stopped at when found.");
}

- (void)testAllWithPredicate
{
    BOOL thereAreNoBigPrimes =  [BITE(primes) allMatchFormat:@"self < %@", @1000];
    XCTAssertFalse(thereAreNoBigPrimes, @"There should be big primes.");
}

- (void)testThatFirstStopsAtFirstMatch
{
    BOOL found;
    NSNumber *firstPrimeGreaterThan1000 = [[BITE(primes) filterWithFormat:@"SELF > 1000"] first:&found];
    XCTAssertTrue(found, @"We should have found one.");
    XCTAssertEqualObjects(firstPrimeGreaterThan1000, primes.knownPrimes.lastObject, @"Enumeration should have stopped at when found.");
    XCTAssertEqualObjects(@1009, firstPrimeGreaterThan1000, @"That's not correct.");
}

- (void)testThatFirstCanMatchNil
{
    BOOL found;
    id nilObject = [[[BITE_AS(primes, NSNumber) filterWithFormat:@"SELF > 1000"] map:^id(NSNumber *obj) {return nil;}] first:&found];
    XCTAssertNil(nilObject, @"It should be nil.");
    XCTAssertTrue(found, @"We should have found one.");
}

- (void)testThatFirstReportsFailure
{
    BOOL found;
    NSNumber *firstPrimeGreaterThan1000 = [[[BITE_AS(primes, NSNumber) take:10] filterWithFormat:@"SELF > 1000"] first:&found];
    XCTAssertFalse(found, @"We should not have found one.");
    XCTAssertNil(firstPrimeGreaterThan1000, @"It should be nil.");
}

- (void)testFoldLeft
{
    id sumPlus10 = [[BITE(primes) take:100] foldLeft:@10 func:^id(id acc, id obj) {
        return @([acc integerValue] + [obj integerValue]);
    }];
    XCTAssertEqualObjects(@(24133+10), sumPlus10, @"Should have summed first 100 primes + 10.");
    
    NSArray *words = @[@"space", @"ant", @"cart", @"squash", @"bug", @"time"];
    
    id shortestWord = [BITE(words) foldLeft:@"------------" func:^id(id acc, id obj) {
        return [obj length] < [acc length] ? obj : acc;
    }];
    XCTAssertEqualObjects(shortestWord, @"ant", @"Should have got first word from the left.");
}

- (void)testFoldRight
{
    id sumPlus10 = [[BITE(primes) take:100] foldRight:@10 func:^id(id obj, id acc) {
        return @([acc integerValue] + [obj integerValue]);
    }];
    XCTAssertEqualObjects(@(24133+10), sumPlus10, @"Should have summed first 100 primes + 10.");
    
    NSArray *words = @[@"space", @"ant", @"cart", @"squash", @"bug", @"time"];
    
    id shortestWord = [BITE(words) foldRight:@"------------" func:^id(id obj, id acc) {
        return [obj length] < [acc length] ? obj : acc;
    }];
    XCTAssertEqualObjects(shortestWord, @"bug", @"Should have got first word from the left.");
}

- (void)testReduceLeft
{
    id sum = [[BITE(primes) take:100] reduceLeft:^id(id acc, id obj) {
        return @([acc integerValue] + [obj integerValue]);
    }];
    XCTAssertEqualObjects(@24133, sum, @"Should have summed first 100 primes.");
    
    NSArray *words = @[@"space", @"ant", @"cart", @"squash", @"bug", @"time"];
    
    id shortestWord = [BITE(words) reduceLeft:^id(id acc, id obj) {
        return [obj length] < [acc length] ? obj : acc;
    }];
    XCTAssertEqualObjects(shortestWord, @"ant", @"Should have got first word from the left.");
}

- (void)testReduceRight
{
    id sum = [[BITE_AS(primes, NSNumber) take:100] reduceRight:^id(NSNumber *obj, id acc) {
        return @([acc integerValue] + [obj integerValue]);
    }];
    XCTAssertEqualObjects(@24133, sum, @"Should have summed first 100 primes.");
    
    NSArray *words = @[@"space", @"ant", @"cart", @"squash", @"bug", @"time"];
    
    id shortestWord = [BITE(words) reduceRight:^id(id obj, id acc) {
        return [obj length] < [acc length] ? obj : acc;
    }];
    XCTAssertEqualObjects(shortestWord, @"bug", @"Should have got first word from the left.");
}

#pragma mark - Bite into

- (void)testBiteIntoKeyPath
{
    BITEEnumerator *items = BITE_INTO(@{@"a":@{@"a":@{@"a":@{@"b":@1}, @"c": @2}}}, @"a");
    
    id innerMostItem = [items last:NULL];
    XCTAssertEqualObjects(@{@"b":@1}, innerMostItem, @"Should have found the inner most item");
    
    id innerMostPassingTest = [[items filterWithFormat:@"c = 2"] last:NULL];
    id expected = @{@"a":@{@"b":@1}, @"c": @2};
    XCTAssertEqualObjects(expected, innerMostPassingTest, @"Should have found the inner most item");
    
    NSArray *firstPrimes = [[BITE(primes) take:100] array];
    NSArray *firstPrimesUsingEnumerator = [[BITE_INTO([firstPrimes asLinkedList], @"next") mapWithKeyPath:@"value"] array];
    XCTAssertEqualObjects(firstPrimes, firstPrimesUsingEnumerator);
}

- (void)testBiteIntoSelector
{
    NSArray *firstPrimes = [[BITE(primes) take:100] array];
    NSArray *firstPrimesUsingEnumerator = [[BITE_INTO_AS([firstPrimes asLinkedList], @selector(next), LinkedList) map:^id(LinkedList *obj) {
        return obj.value;
    }] array];
    XCTAssertEqualObjects(firstPrimes, firstPrimesUsingEnumerator);
}

#pragma mark - Enumerate

- (void)testEnumerate
{
    NSArray *letters = @[@"A", @"B", @"C", @"D"];
    NSArray *indices = @[@0, @1, @2, @3];
    BITEEnumerator *enumerator = [BITE(letters) enumerate];
    
    XCTAssertEqualObjects([[enumerator mapWithFormat:@"_1"] array], indices);
    XCTAssertEqualObjects([[enumerator mapWithFormat:@"_1"] array], indices, @"Indices should be consistent between runs");
    XCTAssertEqualObjects([[enumerator mapWithFormat:@"_2"] array], letters);
    
}

@end

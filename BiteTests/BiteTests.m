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

@interface BiteTests : XCTestCase
{
    PrimeEnumerator *primes;
}

@end

@implementation BiteTests

- (void)setUp
{
    [super setUp];
    primes = [[PrimeEnumerator alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

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

@end

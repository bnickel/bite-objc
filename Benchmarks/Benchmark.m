//
//  Benchmark.m
//  Bite
//
//  Created by Brian Nickel on 5/20/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "Benchmark.h"
#import <Bite/Bite.h>


extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

@interface Benchmark ()
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSMutableArray *data;
@property (nonatomic, readonly) NSMutableArray *tests;
@end

@implementation Benchmark

+ (instancetype)benchmarkWithName:(NSString *)name
{
    NSParameterAssert(name.length > 0);
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _data = [NSMutableArray array];
        _tests = [NSMutableArray array];
    }
    return self;
}

- (void)addTestWithName:(NSString *)name  block:(void (^)(id))block
{
    NSParameterAssert(name.length > 0);
    NSParameterAssert(block != nil);
    [self.tests addObject:BITE_TUPLE(name, block)];
}

- (void)addTestData:(id)data name:(NSString *)name
{
    [self.data addObject:BITE_TUPLE(name, data)];
}

- (void)runWithTrials:(size_t)trials
{
    [self runWithTrials:trials filter:nil];
}

- (void)runWithTrials:(size_t)trials filter:(BOOL(^)(NSString *test, NSString *data))filter
{
    NSDictionary *results = [[[[[BITE([self preparedAndRandomizedTests]) filter:^BOOL(id obj) {
        return filter ? filter([obj _1], [obj _2]) : YES;
    }] map:^id(id test) {
        return BITE_TUPLE([test _1], [test _2], @(dispatch_benchmark(trials, [test _3])));
    }] groupByKeyPath:@"_1"] map:^id(BITEGrouping *group) {
        return BITE_TUPLE([group key], [group dictionaryWithKeyPath:@"_2" valuePath:@"_3"]);
    }] dictionaryWithPairs];
    
    NSMutableString *output = [NSMutableString string];
    [output appendString:self.name];
    [output appendString:@"\n\n"];
    [output appendFormat:@", %@\n", [[BITE(self.tests) mapWithKeyPath:@"_1"] joinedByString:@", "]];
    
    for (id data in self.data) {
        [output appendString:[data _1]];
        for (id test in self.tests) {
            [output appendFormat:@", %@", results[[test _1]][[data _1]] ?: @"skipped"];
        }
        [output appendString:@"\n"];
    }
    [output appendString:@"\n\n"];
    
    NSLog(@"\n%@", output);
}

// _1 = test name, _2 = data name, _3 = block
- (NSArray *)preparedAndRandomizedTests
{
    NSMutableArray *tests = [NSMutableArray array];
    for (id test in self.tests) {
        for (id data in self.data) {
            id argument = [data _2];
            void (^block)(id) = [test _2];
            [tests addObject:BITE_TUPLE([test _1], [data _1], ^{
                block(argument);
            })];
        }
    }
    
    // http://stackoverflow.com/a/10258341/860000
    
    for(NSUInteger i = [tests count]; i > 1; i--) {
        NSUInteger j = arc4random_uniform((u_int32_t)i);
        [tests exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
    
    return [NSArray arrayWithArray:tests];
}


@end

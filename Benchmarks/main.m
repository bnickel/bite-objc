//
//  main.m
//  Benchmarks
//
//  Created by Brian Nickel on 5/19/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <Bite/Bite.h>
#import "Benchmark.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        
        NSArray *items = ({
            const NSUInteger count = 10000;
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
            for (NSUInteger i = 0; i < count; i ++) {
                [items addObject:@(i)];
            }
            [items copy];
        });
        
        Benchmark *benchmark = [Benchmark benchmarkWithName:@"Filtering"];
        [benchmark addTestData:[items subarrayWithRange:NSMakeRange(0, 10)] name:@"10"];
        [benchmark addTestData:[items subarrayWithRange:NSMakeRange(0, 100)] name:@"100"];
        [benchmark addTestData:[items subarrayWithRange:NSMakeRange(0, 1000)] name:@"1000"];
        [benchmark addTestData:[items subarrayWithRange:NSMakeRange(0, 10000)] name:@"10000"];
        
        [benchmark addTestWithName:@"array with predicate" block:^(id items) {
            [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"modulus:by:(SELF,2) == 0"]];
        }];
        
        [benchmark addTestWithName:@"bite with predicate" block:^(id items) {
            [[BITE(items) filterWithFormat:@"modulus:by:(SELF,2) == 0"] array];
        }];
        
        [benchmark addTestWithName:@"array with block" block:^(id items) {
            [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                return [evaluatedObject unsignedIntegerValue] % 2 == 0;
            }]];
        }];
        
        [benchmark addTestWithName:@"bite with block" block:^(id items) {
            [[BITE(items) filter:^BOOL(id obj) {
                return [obj unsignedIntegerValue] % 2 == 0;
            }] array];
        }];
        
        [benchmark runWithTrials:500 filter:^BOOL(NSString *test, NSString *data) {
            return YES;
        }];
        
        return 0;
    }
}

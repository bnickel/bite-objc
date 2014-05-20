//
//  Benchmark.h
//  Bite
//
//  Created by Brian Nickel on 5/20/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Benchmark : NSObject

+ (instancetype)benchmarkWithName:(NSString *)name;
- (void)addTestData:(id)data name:(NSString *)name;
- (void)addTestWithName:(NSString *)name block:(void (^)(id data))block;
- (void)runWithTrials:(size_t)trials;

@end

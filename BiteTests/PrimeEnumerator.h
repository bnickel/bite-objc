//
//  NSPrimeEnumerator.h
//  Bite
//
//  Created by Brian Nickel on 5/19/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrimeEnumerator : NSObject<NSFastEnumeration>
- (NSArray *)knownPrimes;
@end

//
//  BITEGrouping.h
//  Bite
//
//  Created by Brian Nickel on 5/20/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEEnumerator.h"

@interface BITEGrouping<ObjectType> : BITEEnumerator<ObjectType>
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator key:(id<NSCopying>)key;
- (instancetype)initWithEnumerator:(id<NSFastEnumeration>)enumerator key:(id<NSCopying>)key choke:(NSUInteger)choke;
@property (nonatomic, readonly) id<NSCopying> key;
@end

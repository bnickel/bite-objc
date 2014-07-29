//
//  BITEKeyPathEnumerator.h
//  Bite
//
//  Created by Brian Nickel on 7/29/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import "BITEEnumerator.h"

@interface BITEKeyPathEnumerator : NSObject<NSFastEnumeration>
-(instancetype)initWithObject:(id)object keyPath:(NSString *)keyPath;
@end

__attribute__((overloadable)) NS_INLINE BITEEnumerator *BITE_INTO(id object, NSString *keyPath) {
    return BITE([[BITEKeyPathEnumerator alloc] initWithObject:object keyPath:keyPath]);
}

__attribute__((overloadable)) NS_INLINE BITEEnumerator *BITE_INTO(id object, SEL selector) {
    return BITE([[BITEKeyPathEnumerator alloc] initWithObject:object keyPath:NSStringFromSelector(selector)]);
}

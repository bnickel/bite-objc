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
-(instancetype)initWithObject:(id)object selector:(SEL)selector;
@end

__attribute__((overloadable)) NS_INLINE BITEEnumerator *BITE_INTO(id object, NSString *keyPath) {
    return BITE([[BITEKeyPathEnumerator alloc] initWithObject:object keyPath:keyPath]);
}

__attribute__((overloadable)) NS_INLINE BITEEnumerator *BITE_INTO(id object, SEL selector) {
    return BITE([[BITEKeyPathEnumerator alloc] initWithObject:object selector:selector]);
}

#define BITE_INTO_AS(object, selector, kind) ((BITEEnumerator<kind *> *)BITE_INTO((object), (selector)))

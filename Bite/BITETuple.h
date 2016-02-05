//
//  BITETuple.h
//  FastFunctionalOperations
//
//  Created by Brian Nickel on 3/12/14.
//  Copyright (c) 2014 Brian Nickel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BITETuple<T1, T2, T3, T4, T5, T6> : NSObject
@property (nonatomic, strong) T1 _1;
@property (nonatomic, strong) T2 _2;
@property (nonatomic, strong) T3 _3;
@property (nonatomic, strong) T4 _4;
@property (nonatomic, strong) T5 _5;
@property (nonatomic, strong) T6 _6;
@end

__attribute__((overloadable)) NS_INLINE BITETuple *BITE_TUPLE(id _1) {
    BITETuple *tuple = [[BITETuple alloc] init];
    [tuple set_1:_1];
    return tuple;
}

__attribute__((overloadable)) NS_INLINE BITETuple *BITE_TUPLE(id _1, id _2) {
    BITETuple *tuple = [[BITETuple alloc] init];
    [tuple set_1:_1];
    [tuple set_2:_2];
    return tuple;
}

__attribute__((overloadable)) NS_INLINE BITETuple *BITE_TUPLE(id _1, id _2, id _3) {
    BITETuple *tuple = [[BITETuple alloc] init];
    [tuple set_1:_1];
    [tuple set_2:_2];
    [tuple set_3:_3];
    return tuple;
}

#ifdef BITE_SHORTHAND
#define MONAD(_1) BITE_TUPLE(_1)
#define PAIR(_1, _2) BITE_TUPLE(_1, _2)
#define TREBLE(_1, _2, _3) BITE_TUPLE(_1, _2, _3)
#endif

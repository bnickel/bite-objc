//
//  LinkedList.m
//  Bite
//
//  Created by Brian Nickel on 9/16/15.
//  Copyright © 2015 Brian Nickel. All rights reserved.
//

#import "LinkedList.h"

@implementation LinkedList

- (instancetype)initWithValue:(id)value next:(LinkedList *)next
{
    self = [super init];
    if (self) {
        _value = value;
        _next = next;
    }
    return self;
}

@end

@implementation NSArray (LinkedList)

- (LinkedList *)asLinkedList
{
    LinkedList *lastList = nil;
    for (id object in self.reverseObjectEnumerator) {
        lastList = [[LinkedList alloc] initWithValue:object next:lastList];
    }
    
    return lastList;
}

@end

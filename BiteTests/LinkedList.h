//
//  LinkedList.h
//  Bite
//
//  Created by Brian Nickel on 9/16/15.
//  Copyright © 2015 Brian Nickel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinkedList<ItemType> : NSObject
@property (nonatomic, strong, readonly, nonnull) ItemType value;
@property (nonatomic, strong, readonly, nullable) LinkedList<ItemType> *next;
@end

@interface NSArray<ItemType> (LinkedList)
- (nullable LinkedList<ItemType> *)asLinkedList;
@end

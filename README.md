# bite-objc

Bite is a functional enumeration library built on top of `NSFastEnumeration`, providing functions like `take:`, `filter:`, and `map:`. While many Foundation collections already provide similar operations, Bite lets you do them without introducing large or mutable intermediates.

Concept based on the [Bite Java library](https://bitbucket.org/balpha/bite/wiki/Home).

## Usage

### Creating a bite

```objc
BITEEnumerator *bite = BITE(myArray);
BITEEnumerator *bite2 = BITE(myArray, 2); // Never enumerate over more than two elements at a time.

for (id obj in BITE(myArray)) {
    // Use directly in a for-in block.
}
```

### Chaining bites

```objc
BITEEnumerator *bite = [BITE(myArray) filter^BOOL(id obj) { return [obj size].width < 100; }];
BITEEnumerator *bite2 = [bite skip:5];

for (id obj in [bite2 take:5]) {
    [self doSomething:obj];
}
```

### Transforms

- `- (BITEEnumerator *)take:(NSUInteger)count` Stops iterating after `count` elements are iterated.
- `- (BITEEnumerator *)skip:(NSUInteger)count` Skips over `count` elements.

- `- (BITEEnumerator *)map:(id (^)(id obj))mappingFunction` Passes each element through a mapping function and iterates the results.
- `- (BITEEnumerator *)mapWithExpression:(NSExpression *)expression` Same as `map:` but with an expression.
- `- (BITEEnumerator *)mapWithFormat:(NSString *)expressionFormat, ...` Same as `map:` but constructs an expression.
- `- (BITEEnumerator *)mapWithKeyPath:(NSString *)keyPath` Same as `map:` but selects a key path from each element.

- `- (BITEEnumerator *)filter:(BOOL (^)(id obj))test` Only iterates elements that pass a test.  Useful for `nil` filtering before generating a collection.
- `- (BITEEnumerator *)filterWithPredicate:(NSPredicate *)predicate` Same as `filter:` but with a predicate.
- `- (BITEEnumerator *)filterWithFormat:(NSString *)predicateFormat, ...` Same as `filter:` but constructs a predicate.
- `- (BITEEnumerator *)choke:(NSUInteger)choke` Decreases the number of elements that are loaded into the fast-enumeration buffer.
- `- (BITEEnumerator *)except:(id)obj` Filters out elements that are equal to the given object.

### Evaluating/Collecting

- `- (NSArray *)array` Creates an array.
- `- (NSSet *)set` Creates a set.
- `- (NSDictionary *)dictionaryWithKeyPath:(NSString *)keyPath valuePath:(NSString *)valuePath` Creates a dictionary using key paths for the keys and values.
- `- (NSDictionary *)dictionaryWithPairs` Creates a dictionary using the path `_1` for the key and `_2` for the value.  To be used with `PAIR/BITE_TUPLE`.
- `- (NSString *)joinedByString:(NSString *)separator` Joins the elements in the enumerator with a separator.
- `- (BOOL)any:(BOOL (^)(id obj))test` Returns `YES` if any item in the enumerator passes the test and stops iterating.  It chokes the buffer to one element to limit execution.
- `- (BOOL)all:(BOOL (^)(id obj))test` Returns `YES` if all items in the enumerator pass the test.  Returns `NO` and stops iterating as soon as the test fails.  It chokes the buffer to one element to limit execution.
- `- (id)first:(out BOOL *)exists` Returns the first item or `nil` if the enumerator is empty.  Optionally outputs whether or not an item was returned to `exists` in cases where `nil` is a valid enumerated item.

### Tuples

`BITETuple` contains indexed properties `_1`, `_2`, `_3` which can be created with the overloaded `BITE_TUPLE` function.  Shorthand macros exist if you define `BITE_TUPLE` before importing bite:

```objc
id a = BITE_TUPLE(@1);
id b = BITE_TUPLE(@1, @2);
id c = BITE_TUPLE(@1, @2, @3);
// or
id d = MONAD(@1);
id e = PAIR(@1, @2);
id f = TREBLE(@1, @2, @3);

NSParameterAssert([e _2] == [f _2]);
```

## Examples

1. Creating a dictionary from an object using blocks and tuples.

    ```objc
    NSDictionary *networkUsersForSites = [[[BITE(networkUsers) filter:^BOOL(StacManNetworkUser *user) {
        return user.siteUrl != nil;
    }] map:^id(StacManNetworkUser *user) {
        return PAIR(user.siteUrl, user);
    }] dictionaryWithPairs];
    ```
2. Creating the same with predicates and key paths:

    ```objc
    NSDictionary *networkUsersForSites = [[BITE(networkUsers) filterWithFormat:@"siteUrl != nil"]
                                                             dictionaryWithKeyPath:@"siteUrl" valuePath:@"self"];
    ```

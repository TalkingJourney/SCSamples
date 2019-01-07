
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCReusePool : NSObject

- (__kindof NSObject *)dequeueReusableObject;

- (void)addUsingObject:(nonnull NSObject *)object;

- (void)removeUsingObject:(nonnull NSObject *)object;

- (void)resetAllObjects;

@end

NS_ASSUME_NONNULL_END

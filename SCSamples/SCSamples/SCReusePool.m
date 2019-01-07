
#import "SCReusePool.h"
#import <pthread.h>

@interface SCReusePool () {
    NSMutableSet *_usingObjects;
    NSMutableSet *_unusedObjects;
    pthread_mutex_t _lock;
}

@end

@implementation SCReusePool

- (instancetype)init {
    if (self = [super init]) {
        _usingObjects = [NSMutableSet set];
        _unusedObjects = [NSMutableSet set];
        pthread_mutex_init(&_lock, NULL);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

- (__kindof NSObject *)dequeueReusableObject {
    NSObject *object = _unusedObjects.anyObject;
    if (!object) {
        return nil;
    }
    
    pthread_mutex_lock(&_lock);
    [_unusedObjects removeObject:object];
    [_usingObjects addObject:object];
    pthread_mutex_unlock(&_lock);
    
    return object;
}

- (void)addUsingObject:(nonnull NSObject *)object {
    if (!object) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    [_usingObjects addObject:object];
    pthread_mutex_unlock(&_lock);
}

- (void)removeUsingObject:(nonnull NSObject *)object {
    if (!object) {
        return;
    }
    
    if (![_usingObjects containsObject:object]) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    [_usingObjects removeObject:object];
    [_unusedObjects addObject:object];
    pthread_mutex_unlock(&_lock);
}

- (void)resetAllObjects {
    NSObject *object;
    while ((object = _usingObjects.anyObject)) {
        if (pthread_mutex_trylock(&_lock) == 0) {
            [_usingObjects removeObject:object];
            [_unusedObjects addObject:object];
            pthread_mutex_unlock(&_lock);
        } else {
            usleep(10 * 1000); //10 ms
        }
    }
    pthread_mutex_unlock(&_lock);
}

@end

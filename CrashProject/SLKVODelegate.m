//
//  SLKVODelegate.m
//  CrashProject
//
//  Created by jh on 2020/12/20.
//

#import "SLKVODelegate.h"

@interface SLKVOInfo : NSObject

@end

@implementation SLKVOInfo

{
    @package
    void *_context;
    NSKeyValueObservingOptions _options;
    __weak NSObject *_observer;
    NSString *_keyPath;
    
}

@end

@interface SLKVODelegate()
{
    @private
    NSMutableDictionary <NSString *, NSMutableArray<SLKVOInfo *> *>*_keyPathMaps;
    NSLock *_lock;
}
@end

@implementation SLKVODelegate

- (instancetype)init {
    if (self = [super init]) {
        _keyPathMaps = [[NSMutableDictionary alloc] init];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)addKVOInfoToInfoMapsWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context success:(void (^)(void))success failure:(void (^)(void))failure {
    [_lock lock];
    NSMutableArray *KVOInfos = [self getKVOInfosForKeyPath:keyPath];
    __block BOOL isExist = NO;
    [KVOInfos enumerateObjectsUsingBlock:^(SLKVOInfo *  _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        if (info->_observer == observer) {
            isExist = YES;
        }
    }];
    if (isExist) {
        if (failure) {
            failure();
        }
    } else {
        SLKVOInfo *info = [[SLKVOInfo alloc] init];
        info->_observer = observer;
        info->_keyPath = keyPath;
        info->_options = options;
        info->_context = context;
        [KVOInfos addObject:info];
        [self->_keyPathMaps setObject:KVOInfos forKey:keyPath];
        if (success) {
            success();
        }
    }
    [_lock unlock];
}

- (BOOL)removeKVOInfoForKeyPath:(NSString *)keyPath observer:(NSObject *)observer {
    [_lock lock];
    NSMutableArray *infos = [self getKVOInfosForKeyPath:keyPath];
    __block BOOL isExist = NO;
    __block SLKVOInfo *info = nil;
    [infos enumerateObjectsUsingBlock:^(SLKVOInfo *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj->_observer == observer) {
            isExist = YES;
            info = obj;
        }
    }];
    if (isExist) {
        [infos removeObject:info];
    }
    [_lock unlock];
    return isExist;
}

- (NSMutableArray *)getKVOInfosForKeyPath:(NSString *)keyPath {
    if ([_keyPathMaps.allKeys containsObject:keyPath]) {
        return [_keyPathMaps objectForKey:keyPath];
    } else {
        return [[NSMutableArray alloc] init];
    }
}

- (NSArray *)getAllKeyPaths {
    return self->_keyPathMaps.allKeys;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSMutableArray *infos = [self getKVOInfosForKeyPath:keyPath];
    [infos enumerateObjectsUsingBlock:^(SLKVOInfo *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj->_keyPath isEqualToString:keyPath]) {
            NSObject *observer = obj->_observer;
            if (observer) {
                [observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            }
        }
    }];
}
@end

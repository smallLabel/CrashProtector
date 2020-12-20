//
//  SLKVODelegate.h
//  CrashProject
//
//  Created by jh on 2020/12/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SLKVODelegate : NSObject

- (void)addKVOInfoToInfoMapsWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context success:(void (^)(void))success failure:(void (^)(void))failure;

- (BOOL)removeKVOInfoForKeyPath:(NSString *)keyPath observer:(NSObject *)observer;

- (NSArray *)getAllKeyPaths;
@end

NS_ASSUME_NONNULL_END

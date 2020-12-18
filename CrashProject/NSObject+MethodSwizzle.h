//
//  NSObject+MethodSwizzle.h
//  CrashProject
//
//  Created by jh on 2020/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MethodSwizzle)

+ (void)swizzelInstanceMethod:(Class)targetClass originalSelector:(SEL)originalSelector swizzleSelector:(SEL)swizzleSelector;

+ (void)swizzelClassMethod:(Class)targetClass originalSelector:(SEL)originalSelector swizzleSelector:(SEL)swizzleSelector;

@end

NS_ASSUME_NONNULL_END

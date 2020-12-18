//
//  NSObject+Selector.m
//  CrashProject
//
//  Created by jh on 2020/12/17.
//

#import "NSObject+Selector.h"
#import "NSObject+MethodSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (Selector)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSObject swizzelInstanceMethod:[self class] originalSelector:@selector(forwardingTargetForSelector:) swizzleSelector:@selector(sl_forwardingTargetForSelector:)];
    });
}

- (id)sl_forwardingTargetForSelector:(SEL)selector {
    if([self isEqual:[NSNull null]] || ![self overideForwardingMethods]) {
        NSString *errClassName = NSStringFromClass([self class]);
        NSString *errSel = NSStringFromSelector(selector);
        NSLog(@"%@  %@", errClassName, errSel);
        
        NSString *classname = @"CrashClass";
        
        Class cls  = NSClassFromString(classname);
        if (!cls) {
            // 创建动态类
            Class superClass = [NSObject class];
            cls = objc_allocateClassPair(superClass, classname.UTF8String, 0);
            objc_registerClassPair(cls);
        }
        
        if (!class_getInstanceMethod(NSClassFromString(classname), selector)) {
            // 为selector添加实现
            class_addMethod(cls, selector, (IMP)Crash, "@@:@");
        }
        return  [[cls alloc] init];
    }
    return [self sl_forwardingTargetForSelector:selector];
}
static int Crash(id slf, SEL selector) {
    return  0;
}

// 判断是否已经做了第二步和第三步转发
- (BOOL)overideForwardingMethods {
    BOOL overide = NO;
    overide = (class_getMethodImplementation([NSObject class], @selector(forwardingTargetForSelector:)) != class_getMethodImplementation([self class], @selector(forwardingTargetForSelector:))) || (class_getMethodImplementation([NSObject class], @selector(forwardInvocation:)) != class_getMethodImplementation([self class], @selector(forwardInvocation:)));
    return overide;
}
@end

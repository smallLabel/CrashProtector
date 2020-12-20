//
//  NSObject+Selector.m
//  CrashProject
//
//  Created by jh on 2020/12/17.
//

#import "NSObject+Selector.h"
#import "NSObject+MethodSwizzle.h"
#import <objc/runtime.h>
#import "SLKVODelegate.h"


static inline BOOL IsSystemClass(Class cls) {
    NSString *className = NSStringFromClass(cls);
    if ([className hasPrefix:@"NS"]) {
        return  YES;
    }
    NSBundle *bundle = [NSBundle bundleForClass:cls];
    if (bundle == [NSBundle mainBundle]) {
        return  YES;
    }
    return  NO;
}



@implementation NSObject (Selector)

static NSString *const KVODelegate = @"kvoDelegate";
- (void)setKVODelegate:(SLKVODelegate *)kvoDelegate {
    objc_setAssociatedObject(self, (__bridge void *)KVODelegate, kvoDelegate, OBJC_ASSOCIATION_RETAIN);
}

- (SLKVODelegate *)KVODelegate {
    id delegate = objc_getAssociatedObject(self, (__bridge void *)KVODelegate);
    if (!delegate) {
        delegate =[[SLKVODelegate alloc] init];
        self.KVODelegate = delegate;
    }
    return delegate;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换消息转发流程中第二步系统实现
        [NSObject swizzleInstanceMethod:[self class] originalSelector:@selector(forwardingTargetForSelector:) swizzleSelector:@selector(sl_forwardingTargetForSelector:)];
        // KVO
        [NSObject swizzleInstanceMethod:[self class] originalSelector:@selector(addObserver:forKeyPath:options:context:) swizzleSelector:@selector(sl_addObserver:forKeyPath:options:context:)];
        [NSObject swizzleInstanceMethod:[self class] originalSelector:@selector(removeObserver:forKeyPath:) swizzleSelector:@selector(sl_removeObserver:forKeyPath:)];
        [NSObject swizzleInstanceMethod:[self class] originalSelector:@selector(removeObserver:forKeyPath:context:) swizzleSelector:@selector(sl_removeObserver:forKeyPath:context:)];
        [NSObject swizzleInstanceMethod:[self class] originalSelector:NSSelectorFromString(@"dealloc") swizzleSelector:@selector(sl_dealloc)];
    });
}

//
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

- (void)sl_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    if (!IsSystemClass(self.class)) {
        __weak __typeof(self)weakSelf = self;
        [self.KVODelegate addKVOInfoToInfoMapsWithObserver:observer keyPath:keyPath options:options context:context success:^{
            [weakSelf sl_addObserver:observer forKeyPath:keyPath options:options context:context];
                } failure:^{
                    NSLog(@"添加失败");
                }];
    } else {
        [self sl_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}
- (void)sl_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if (!IsSystemClass(self.class)) {
        if ([self.KVODelegate removeKVOInfoForKeyPath:keyPath observer:observer]) {
            [self sl_removeObserver:self.KVODelegate forKeyPath:keyPath];
        }
    } else {
        [self sl_removeObserver:observer forKeyPath:keyPath];
    }
}
- (void)sl_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    if (!IsSystemClass(self.class)) {
        if ([self.KVODelegate removeKVOInfoForKeyPath:keyPath observer:observer]) {
            [self sl_removeObserver:self.KVODelegate forKeyPath:keyPath];
        }
            
    } else {
        [self sl_removeObserver:observer forKeyPath:keyPath context:context];
    }
}
- (void)sl_dealloc {
    if (!IsSystemClass(self.class)) {
        NSArray *keyPaths = [self.KVODelegate getAllKeyPaths];
        if (keyPaths.count > 0) {
            [keyPaths enumerateObjectsUsingBlock:^(NSString *  _Nonnull keyPath, NSUInteger idx, BOOL * _Nonnull stop) {
                [self sl_removeObserver:self.KVODelegate forKeyPath:keyPath];
            }];
        }
    }
    [self sl_dealloc];
    
}

@end

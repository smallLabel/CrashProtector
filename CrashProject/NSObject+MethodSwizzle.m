//
//  NSObject+MethodSwizzle.m
//  CrashProject
//
//  Created by jh on 2020/12/17.
//

#import "NSObject+MethodSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzle)

+ (void)swizzleClassMethod:(Class)targetClass originalSelector:(SEL)originalSelector swizzleSelector:(SEL)swizzleSelector {
    swizzlingClassMethod(targetClass, originalSelector, swizzleSelector);
}


+ (void)swizzleInstanceMethod:(Class)targetClass originalSelector:(SEL)originalSelector swizzleSelector:(SEL)swizzleSelector {
    swizzlingInstanceMethod(targetClass, originalSelector, swizzleSelector);
}

void swizzlingClassMethod(Class class, SEL originalSelector, SEL swizzlingSelector) {
    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzlingMethod = class_getClassMethod(class, swizzlingSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(originalMethod), method_getTypeEncoding(swizzlingMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzlingSelector, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzlingMethod);
    }
    
}

void swizzlingInstanceMethod(Class class, SEL originalSelector, SEL swizzlingSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzlingMethod = class_getInstanceMethod(class, swizzlingSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(originalMethod), method_getTypeEncoding(swizzlingMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class, swizzlingSelector, method_getImplementation(swizzlingMethod), method_getTypeEncoding(swizzlingMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzlingMethod);
    }
}
@end

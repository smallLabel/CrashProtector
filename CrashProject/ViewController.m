//
//  ViewController.m
//  CrashProject
//
//  Created by jh on 2020/12/17.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "Person.h"

@interface ViewController ()
@property(nonatomic, strong) Person *xiaoming;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _xiaoming = [[Person alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [[[NSObject alloc] init] performSelector:@selector(hello)];
//    [self.xiaoming addObserver:self forKeyPath:@"hello" options:NSKeyValueObservingOptionNew context:nil];
//    [self removeObserver];
//    [self removeNilKeyPath];
    [self normal];
}


- (void)removeObserver {
    [self.xiaoming removeObserver:self forKeyPath:@"nihao"];
}

- (void)removeNilKeyPath {
//    [self.xiaoming addObserver:self forKeyPath:nil options:NSKeyValueObservingOptionNew context:nil];
    [self.xiaoming removeObserver:self forKeyPath:nil];
}

- (void)normal {
    [self.xiaoming addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew context:nil];
    self.xiaoming.age = rand()%100;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@", change);
}

@end

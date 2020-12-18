//
//  ViewController.m
//  CrashProject
//
//  Created by jh on 2020/12/17.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIDevice *de;
    CMSensorRecorder *r;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[[NSObject alloc] init] performSelector:@selector(hello)];
}


@end

//
//  JPWeakTimer.m
//  test
//
//  Created by ovopark_iOS on 16/8/22.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#define JPWeakTimer_SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#import "JPWeakTimer.h"

@interface JPWeakTimer ()

@property (weak, nonatomic) id target;
@property (assign, nonatomic) SEL selector;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation JPWeakTimer

+ (JPWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo
{
    JPWeakTimer *weakTimer = [[JPWeakTimer alloc] init];
    
    weakTimer.target = aTarget;
    weakTimer.selector = aSelector;
    
    weakTimer.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:weakTimer selector:@selector(timerAction:) userInfo:userInfo repeats:yesOrNo];
    
    return weakTimer;
}

- (void)timerAction:(NSTimer *)sender
{
    if (self.target) {
        JPWeakTimer_SuppressPerformSelectorLeakWarning([self.target performSelector:self.selector withObject:self]);
    } else {
        // 当本类实例被释放之后，定时器还会循环触发方法，这时self已经为空，就会自动进入这里停止计时
        [self.timer invalidate];
    }
}

- (void)fire
{
    [self.timer fire];
}

- (void)invalidate
{
    [self.timer invalidate];
}

- (BOOL)isValid
{
    return self.timer.isValid;
}

- (NSTimeInterval)timeInterval
{
    return self.timer.timeInterval;
}

- (id)userInfo
{
    return self.timer.userInfo;
}

@end

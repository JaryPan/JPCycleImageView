//
//  JPWeakTimer.h
//  test
//
//  Created by ovopark_iOS on 16/8/22.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JPWeakTimer : NSObject

+ (JPWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo;

- (void)fire;

- (void)invalidate;

@property (readonly, getter=isValid) BOOL valid;

@property (readonly) NSTimeInterval timeInterval;

@property (readonly, retain) id userInfo;

@end

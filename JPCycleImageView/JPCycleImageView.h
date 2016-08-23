//
//  JPCycleImageView.h
//  JPCycleImageView
//
//  Created by ovopark_iOS on 16/8/9.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JPCycleImageViewDelegate;

@interface JPCycleImageView : UIView

/*
 代理属性
 */
@property (weak, nonatomic) id<JPCycleImageViewDelegate>delegate;

/*
 是否启用定时器，默认YES；
 设置为NO将会停止计时，设置为YES将会启动定时。
 */
@property (assign, nonatomic) BOOL timerEnabled;
/*
 图片切换的时间间隔，默认3s
 */
@property (assign, nonatomic) NSTimeInterval timerTimeInterval;
/*
 图片切换时的动画时间，默认0.2s
 */
@property (assign, nonatomic) CGFloat animationTime;

/*
 dataSource 可以是图片url字符串数组，也可以是图片数组，还可以是url字符串和图片混合数组
 如果 timerEnabled=YES，设置dataSource后将会暂时停止计时器，reloadData方法执行后会自动开启。
 */
@property (strong, nonatomic) NSArray *dataSource;

/*
 刷新视图的方法
 触发该方法会使图片切换到第一张，如果 timerEnabled=YES，会自动开启定时器
 */
- (void)reloadData;


/*
 占位图，用于展示在网络图片未加载出来之前
 */
@property (strong, nonatomic) UIImage *placeholderImage;

/*
 图片填充方式，会影响展示图和占位图的图片填充方式
 */
@property (assign, nonatomic) UIViewContentMode contentMode;


/*
 是否展示图片加载指示器，默认NO
 */
@property (assign, nonatomic) BOOL showActivityIndicator;
/*
 加载指示器的颜色
 */
@property (strong, nonatomic) UIColor *activityIndicatorColor;


/*
 是否展示页数指示器，默认YES
 */
@property (assign, nonatomic) BOOL showPageIndicator;
/*
 页数指示器的一般颜色
 */
@property (strong, nonatomic) UIColor *pageIndicatorColor;
/*
 页数指示器的当前颜色
 */
@property (strong, nonatomic) UIColor *currentPageIndicatorColor;


/*
 清除缓存
 */
- (void)clearCaches;

@end

@protocol JPCycleImageViewDelegate <NSObject>

@optional
/* 
 点击了某张图片 
 */
- (void)cycleImageView:(JPCycleImageView *)cycleImageView clickedImage:(UIImage *)image atIndex:(NSInteger)index;
/*
 从旧下标处滑动到新下标出处
 */
- (void)cycleImageView:(JPCycleImageView *)cycleImageView didScrollToIndex:(NSInteger)newIndex fromIndex:(NSInteger)oldIndex;

@end

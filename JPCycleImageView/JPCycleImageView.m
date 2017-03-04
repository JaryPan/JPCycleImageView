//
//  JPCycleImageView.m
//  JPCycleImageView
//
//  Created by ovopark_iOS on 16/8/9.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import "JPCycleImageView.h"
#import "JPCycleImageViewContentView.h"
#import "JPWeakTimer.h"
#import "JPImageDownloader.h"

@interface JPCycleImageView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *imageScrollView;

@property (strong, nonatomic) JPCycleImageViewContentView *contentView1;
@property (strong, nonatomic) JPCycleImageViewContentView *contentView2;
@property (strong, nonatomic) JPCycleImageViewContentView *contentView3;

@property (strong, nonatomic) UIPageControl *pageControl;

@property (strong, nonatomic) JPWeakTimer *timer;

@property (assign, nonatomic) CGPoint oldOffset;
@property (assign, nonatomic) CGPoint newOffset;
@property (assign, nonatomic) NSInteger index;

@end

@implementation JPCycleImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.timerEnabled = YES;
        self.timerTimeInterval = 3.0;
        self.animationTime = 0.2;
        self.showPageIndicator = YES;
        [self addSubviews];
        // 设置最大缓存
        [JPImageDownloader setMaxMemoryCachesSize:30*1024*1024];
        [JPImageDownloader setMaxDiskCachesSize:50*1024*1024];
    }
    return self;
}

#pragma mark - addSubviews
- (void)addSubviews
{
    self.imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.imageScrollView.showsVerticalScrollIndicator = NO;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.delegate = self;
    self.imageScrollView.contentOffset = CGPointMake(self.frame.size.width, 0);
    [self addSubview:self.imageScrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20)];
    self.pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:80.0/255.0 green:160.0/255.0 blue:245.0/255.0 alpha:1.0];
    [self addSubview:self.pageControl];
}

#pragma amrk - layoutSubviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageScrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.contentView1.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.contentView2.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    self.contentView3.frame = CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height);
    
    self.pageControl.frame = CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20);
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.timerEnabled) {
        [self stopTimer];
    }
    
    self.oldOffset = scrollView.contentOffset;
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    scrollView.userInteractionEnabled = NO;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.timerEnabled) {
        [self startTimer];
    }
    
    scrollView.userInteractionEnabled = YES;
    
    self.newOffset = scrollView.contentOffset;
    
    // 记录原来的下标
    NSInteger oldIndex = self.index;
    
    if (self.newOffset.x > self.oldOffset.x) {
        // 滑到了下一张
        
        // 下标增加
        self.index++;
        if (self.index == self.dataSource.count) {
            // 超过了最后一张
            self.index = 0;
        }
        
        [self.contentView2 cancelLoadingImage];
        
        if (self.contentView3.image) {
            self.contentView2.urlOrImage = self.contentView3.image;
        } else {
            self.contentView3.urlOrImage = self.dataSource[self.index];
            self.contentView2.urlOrImage = self.dataSource[self.index];
            [self.contentView2 loadImageWithActivityIndicator:self.showActivityIndicator];
        }
    } else if (self.newOffset.x < self.oldOffset.x) {
        // 滑到了上一张
        self.index--;
        if (self.index < 0) {
            // 超过了第一张
            self.index = self.dataSource.count - 1;
        }
        
        [self.contentView2 cancelLoadingImage];
        
        if (self.contentView1.image) {
            self.contentView2.urlOrImage = self.contentView1.image;
        } else {
            self.contentView1.urlOrImage = self.dataSource[self.index];
            self.contentView2.urlOrImage = self.dataSource[self.index];
            [self.contentView2 loadImageWithActivityIndicator:self.showActivityIndicator];
        }
    }
    
    // 实现代理
    if (self.newOffset.x != self.oldOffset.x) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cycleImageView:didScrollToIndex:fromIndex:)]) {
            [self.delegate cycleImageView:self didScrollToIndex:self.index fromIndex:oldIndex];
        }
    }
    
    // 恢复偏移量
    scrollView.contentOffset = CGPointMake(scrollView.frame.size.width, 0);
    
    // 设置页面控制器的位置
    self.pageControl.currentPage = self.index;
    
    // 还原正常的图片顺序
    NSInteger firstIndex = (self.index - 1 < 0 ? self.dataSource.count - 1 : self.index - 1);
    NSInteger lastIndex = (self.index + 1 == self.dataSource.count ? 0 : self.index + 1);
    self.contentView1.urlOrImage = self.dataSource[firstIndex];
    self.contentView3.urlOrImage = self.dataSource[lastIndex];
    [self.contentView1 loadImageWithActivityIndicator:self.showActivityIndicator];
    [self.contentView3 loadImageWithActivityIndicator:self.showActivityIndicator];
}


#pragma mark - setTimerEnbled
- (void)setTimerEnabled:(BOOL)timerEnabled
{
    _timerEnabled = timerEnabled;
    
    if (timerEnabled) {
        [self startTimer];
    } else {
        [self stopTimer];
    }
}
#pragma mark - startTimer，stopTimer
- (void)startTimer
{
    if (!self.timer.isValid) {
        self.timer = [JPWeakTimer scheduledTimerWithTimeInterval:self.timerTimeInterval target:self selector:@selector(timerToChangeImageLocation:) userInfo:nil repeats:YES];
    }
}
- (void)stopTimer
{
    [self.timer invalidate];
    self.timer = nil;
}
#pragma mark - timerToChangeImageLocation
- (void)timerToChangeImageLocation:(JPWeakTimer *)sender
{
    // 修改偏移量
    [UIView animateWithDuration:self.animationTime animations:^{
        self.imageScrollView.contentOffset = CGPointMake(2*self.imageScrollView.frame.size.width, 0);
    } completion:^(BOOL finished) {
        // 记录原来的下标
        NSInteger oldIndex = self.index;
        
        // 下标增加
        self.index++;
        if (self.index == self.dataSource.count) {
            // 超过了最后一张
            self.index = 0;
        }
        
        [self.contentView2 cancelLoadingImage];
        
        if (self.contentView3.image) {
            self.contentView2.urlOrImage = self.contentView3.image;
        } else {
            self.contentView3.urlOrImage = self.dataSource[self.index];
            self.contentView2.urlOrImage = self.dataSource[self.index];
            [self.contentView2 loadImageWithActivityIndicator:self.showActivityIndicator];
        }
        
        // 实现代理
        if (self.delegate && [self.delegate respondsToSelector:@selector(cycleImageView:didScrollToIndex:fromIndex:)]) {
            [self.delegate cycleImageView:self didScrollToIndex:self.index fromIndex:oldIndex];
        }
        
        // 恢复偏移量
        self.imageScrollView.contentOffset = CGPointMake(self.imageScrollView.frame.size.width, 0);
        
        // 设置页面控制器的位置
        self.pageControl.currentPage = self.index;
        
        // 还原正常的图片顺序
        NSInteger firstIndex = (self.index - 1 < 0 ? self.dataSource.count - 1 : self.index - 1);
        NSInteger lastIndex = (self.index + 1 == self.dataSource.count ? 0 : self.index + 1);
        self.contentView1.urlOrImage = self.dataSource[firstIndex];
        self.contentView3.urlOrImage = self.dataSource[lastIndex];
        [self.contentView1 loadImageWithActivityIndicator:self.showActivityIndicator];
        [self.contentView3 loadImageWithActivityIndicator:self.showActivityIndicator];
    }];
}
#pragma amrk - setTimerTimeInterval
- (void)setTimerTimeInterval:(NSTimeInterval)timerTimeInterval
{
    _timerTimeInterval = timerTimeInterval;
}


#pragma mark - setDataSource
- (void)setDataSource:(NSArray *)dataSource
{
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
    }
    
    if (!self.contentView1) {
        self.contentView1 = [[JPCycleImageViewContentView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.contentView1.placeholderImage = self.placeholderImage;
        self.contentView1.contentMode = self.contentMode;
        [self.contentView1 addTarget:self action:@selector(contentViewTapAction:)];
        [self.imageScrollView addSubview:self.contentView1];
    }
    
    if (!self.contentView2) {
        self.contentView2 = [[JPCycleImageViewContentView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        self.contentView2.placeholderImage = self.placeholderImage;
        self.contentView2.contentMode = self.contentMode;
        [self.contentView2 addTarget:self action:@selector(contentViewTapAction:)];
        [self.imageScrollView addSubview:self.contentView2];
    }
    
    if (!self.contentView3) {
        self.contentView3 = [[JPCycleImageViewContentView alloc] initWithFrame:CGRectMake(self.frame.size.width*2, 0, self.frame.size.width, self.frame.size.height)];
        self.contentView3.placeholderImage = self.placeholderImage;
        self.contentView3.contentMode = self.contentMode;
        [self.contentView3 addTarget:self action:@selector(contentViewTapAction:)];
        [self.imageScrollView addSubview:self.contentView3];
    }
    
    self.pageControl.numberOfPages = self.dataSource.count;
    
    [self stopTimer];
}
- (void)contentViewTapAction:(JPCycleImageViewContentView *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cycleImageView:didClickImage:atIndex:)]) {
        [self.delegate cycleImageView:self didClickImage:sender.image atIndex:self.index];
    }
}


#pragma mark - reloadData
- (void)reloadData
{
    NSInteger contentCount = self.dataSource.count;
    if (contentCount > 3) {
        contentCount = 3;
    }
    // 设置滑动范围
    self.imageScrollView.contentSize = CGSizeMake(self.imageScrollView.frame.size.width*contentCount, 0);
    // 重置初始偏移量
    self.imageScrollView.contentOffset = CGPointMake(self.imageScrollView.frame.size.width, 0);
    // 重设下标
    self.index = 0;
    // 重置页面控制器的初始位置
    self.pageControl.currentPage = 0;
    
    if (self.dataSource.count > 0) {
        self.contentView1.urlOrImage = [self.dataSource lastObject];
        self.contentView2.urlOrImage = [self.dataSource firstObject];
        if (self.dataSource.count == 1) {
            self.contentView3.urlOrImage = self.dataSource[0];
        } else {
            self.contentView3.urlOrImage = self.dataSource[1];
        }
        
        [self.contentView1 loadImageWithActivityIndicator:self.showActivityIndicator];
        [self.contentView2 loadImageWithActivityIndicator:self.showActivityIndicator];
        [self.contentView3 loadImageWithActivityIndicator:self.showActivityIndicator];
    }
    
    if (self.timerEnabled) {
        [self startTimer];
    }
}


#pragma mark - setPlaceholderImage
- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    if (_placeholderImage != placeholderImage) {
        _placeholderImage = placeholderImage;
    }
    
    self.contentView1.placeholderImage = placeholderImage;
    self.contentView2.placeholderImage = placeholderImage;
    self.contentView3.placeholderImage = placeholderImage;
}

#pragma mark - setContentMode
- (void)setContentMode:(UIViewContentMode)contentMode
{
    _contentMode = contentMode;
    
    self.contentView1.contentMode = contentMode;
    self.contentView2.contentMode = contentMode;
    self.contentView3.contentMode = contentMode;
}


#pragma mark - setActivityIndicatorColor
- (void)setActivityIndicatorColor:(UIColor *)activityIndicatorColor
{
    if (_activityIndicatorColor != activityIndicatorColor) {
        _activityIndicatorColor = activityIndicatorColor;
    }
    
    self.contentView1.activityIndicatorColor = activityIndicatorColor;
    self.contentView2.activityIndicatorColor = activityIndicatorColor;
    self.contentView3.activityIndicatorColor = activityIndicatorColor;
}


#pragma mark - setShowPageIndicator
- (void)setShowPageIndicator:(BOOL)showPageIndicator
{
    _showPageIndicator = showPageIndicator;
    
    self.pageControl.hidden = !showPageIndicator;
}
#pragma mark - setPageIndicatorColor
- (void)setPageIndicatorColor:(UIColor *)pageIndicatorColor
{
    if (_pageIndicatorColor != pageIndicatorColor) {
        _pageIndicatorColor = pageIndicatorColor;
    }
    
    self.pageControl.pageIndicatorTintColor = pageIndicatorColor;
}
#pragma mark - setCurrentPageIndicatorColor
- (void)setCurrentPageIndicatorColor:(UIColor *)currentPageIndicatorColor
{
    if (_currentPageIndicatorColor != currentPageIndicatorColor) {
        _currentPageIndicatorColor = currentPageIndicatorColor;
    }
    
    self.pageControl.currentPageIndicatorTintColor = currentPageIndicatorColor;
}


#pragma mark - clearCaches
- (void)clearCaches
{
    [JPImageDownloader clearMemoryCaches];
    [JPImageDownloader clearDiskCaches:nil];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

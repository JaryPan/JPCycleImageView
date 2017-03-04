//
//  JPCycleImageViewContentView.m
//  JPCycleImageView
//
//  Created by ovopark_iOS on 16/8/9.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

// 处理 target - action 警告
#define kJPCycleImageViewContentViewSuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#import "JPCycleImageViewContentView.h"
#import "JPImageDownloader.h"

@interface JPCycleImageViewContentView ()

@property (weak, nonatomic) id target;
@property (assign, nonatomic) SEL action;

@property (strong, nonatomic) UIImageView *placeholderImageView;
@property (strong, nonatomic) UIImageView *imageView;

@property (copy, nonatomic) NSString *imageUrl;

@property (strong, nonatomic) UIActivityIndicatorView *aiv;

@end

@implementation JPCycleImageViewContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.imageView];
        
        // 添加点击手势
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    }
    return self;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.placeholderImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.aiv.center = self.center;
}


#pragma mark - tapAction
- (void)tapAction:(UITapGestureRecognizer *)sender
{
    if (self.target && self.action) {
        kJPCycleImageViewContentViewSuppressPerformSelectorLeakWarning([self.target performSelector:self.action withObject:self]);
    }
}


#pragma mark - setUrlOrImage
- (void)setUrlOrImage:(id)urlOrImage
{
    if (_urlOrImage != urlOrImage) {
        _urlOrImage = urlOrImage;
    }
    
    self.imageView.image = nil;
    
    if ([urlOrImage isKindOfClass:[NSString class]]) {
        self.imageUrl = urlOrImage;
    } else if ([urlOrImage isKindOfClass:[UIImage class]]) {
        self.imageView.image = urlOrImage;
    }
}

#pragma mark - setPlaceholderImage
- (void)setPlaceholderImage:(UIImage *)placeholderImage
{
    if (_placeholderImage != placeholderImage) {
        _placeholderImage = placeholderImage;
    }
    
    if (!self.placeholderImageView) {
        self.placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.placeholderImageView];
        
        [self bringSubviewToFront:self.imageView];
        if (self.aiv) {
            [self bringSubviewToFront:self.aiv];
        }
    }
    
    self.placeholderImageView.image = placeholderImage;
}

#pragma mark - setContentModel
- (void)setContentMode:(UIViewContentMode)contentMode
{
    _contentMode = contentMode;
    
    self.placeholderImageView.contentMode = contentMode;
    self.imageView.contentMode = contentMode;
}

#pragma mark - activityIndicatorColor
- (UIColor *)activityIndicatorColor
{
    if (_activityIndicatorColor) {
        return _activityIndicatorColor;
    } else {
        return [UIColor whiteColor];
    }
}

#pragma mark - image
- (UIImage *)image
{
    return self.imageView.image;
}


#pragma mark - addTarget:action:
- (void)addTarget:(id)target action:(SEL)action
{
    self.target = target;
    self.action = action;
}


#pragma mark - loadImageWithActivityIndicator
- (void)loadImageWithActivityIndicator:(BOOL)showIndicator
{
    if ([self.urlOrImage isKindOfClass:[NSString class]]) {
        if (showIndicator) {
            if (!self.aiv) {
                self.aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                self.aiv.center = self.center;
                // 如果不添加到父视图上，总是会出现自动跑到视图最后边的异常
                [self.superview addSubview:self.aiv];
            }
            
            self.aiv.color = self.activityIndicatorColor;
            [self.aiv startAnimating];
            
            [JPImageDownloader imageWithUrlString:self.imageUrl completionHandler:^(UIImage * _Nullable image, NSError * _Nullable error, JPImageCacheType cacheType, NSURL * _Nullable imageURL) {
                self.imageView.image = image;
                [self.aiv stopAnimating];
            }];
        } else {
            [JPImageDownloader imageWithUrlString:self.imageUrl completionHandler:^(UIImage * _Nullable image, NSError * _Nullable error, JPImageCacheType cacheType, NSURL * _Nullable imageURL) {
                self.imageView.image = image;
            }];
        }
    } else if ([self.urlOrImage isKindOfClass:[UIImage class]]) {
        self.imageView.image = self.urlOrImage;
    }
}

#pragma mark - cancelLoadingImage
- (void)cancelLoadingImage
{
    if ([self.imageUrl isKindOfClass:[NSString class]]) {
        [JPImageDownloader cancelWithUrlString:self.imageUrl];
        if (self.aiv) {
            [self.aiv stopAnimating];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

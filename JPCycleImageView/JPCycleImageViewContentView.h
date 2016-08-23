//
//  JPCycleImageViewContentView.h
//  JPCycleImageView
//
//  Created by ovopark_iOS on 16/8/9.
//  Copyright © 2016年 JaryPan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPCycleImageViewContentView : UIView

@property (strong, nonatomic) id urlOrImage;

@property (strong, nonatomic) UIImage *placeholderImage;

@property (assign, nonatomic) UIViewContentMode contentMode;

@property (strong, nonatomic) UIColor *activityIndicatorColor;

@property (strong, nonatomic, readonly) UIImage *image;

- (void)addTarget:(id)target action:(SEL)action;

- (void)loadImageWithActivityIndicator:(BOOL)showIndicator;

- (void)cancelLoadingImage;

@end

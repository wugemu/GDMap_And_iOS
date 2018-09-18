//
//  ViewController.h
//  LBSMapDemo
//
//  Created by unispeed on 2018/3/7.
//  Copyright © 2018年 Ding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@protocol ViewControllerDelegate <NSObject>

- (BOOL)viewController:(ViewController*)vc itemSelected:(NSString *)itemClassName title:(NSString *)title;
- (NSString *)viewController:(ViewController*)vc displayTileOf:(NSString *)itemClassName;


@end


@interface ViewController : UIViewController

@property (nonatomic, weak) id<ViewControllerDelegate> delegate;

@end


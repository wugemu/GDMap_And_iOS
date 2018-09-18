//
//  ChangeLogoPositionViewController.m
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/8/16.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import "ChangeLogoPositionViewController.h"
#import "UIView+Toast.h"

@interface ChangeLogoPositionViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, assign) CGFloat logoCenterX;

@end

@implementation ChangeLogoPositionViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"改变logo位置"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(changeLogoPosition)];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    self.logoCenterX = self.mapView.logoCenter.x;
    [self.view addSubview:self.mapView];
    
}

- (void)changeLogoPosition {
    CGPoint oldCenter = self.mapView.logoCenter;
    self.mapView.logoCenter = CGPointMake(oldCenter.x > self.view.bounds.size.width / 2 ? self.logoCenterX : self.mapView.bounds.size.width - self.logoCenterX, oldCenter.y);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
#pragma mark - Action Handlers
- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

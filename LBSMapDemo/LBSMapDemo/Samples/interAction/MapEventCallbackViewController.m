//
//  MapEventCallbackViewController.m
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/8/12.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import "MapEventCallbackViewController.h"
#import "UIView+Toast.h"

@interface MapEventCallbackViewController ()<MAMapViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation MapEventCallbackViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    
    [self setupGestures]; //自行在地图上添加一些手势
}

/**
 如果开发者觉得地图内部手势的回调不够用，也可自行添加手势，但需要做一些额外的处理，才能保证地图内部的手势和自行添加的手势都能工作
 */
- (void)setupGestures
{
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    self.doubleTap.delegate = self;
    self.doubleTap.numberOfTapsRequired = 2;
    [self.mapView addGestureRecognizer:self.doubleTap];
    
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    self.singleTap.delegate = self;
    [self.singleTap requireGestureRecognizerToFail:self.doubleTap];
    [self.mapView addGestureRecognizer:self.singleTap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.mapView.delegate = self;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

/**
 返回NO，就是自行添加的手势不触发，返回YES就是触发
 比如，地图上有AnnotationView，单击了AnnotationView，既可以只相应地图内部的手势，也可以都响应，开发者可以根据需要，自行进行条件的组合来判断
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == self.singleTap && ([touch.view isKindOfClass:[UIControl class]] || [touch.view isKindOfClass:[MAAnnotationView class]]))
    {
        return NO;
    }
    
    if (gestureRecognizer == self.doubleTap && [touch.view isKindOfClass:[UIControl class]])
    {
        return NO;
    }
    
    return YES;
}


#pragma mark 自行添加的手势的回调

- (void)handleSingleTap:(UITapGestureRecognizer *)theSingleTap
{
    NSLog(@"my single tap");
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)theDoubleTap
{
    NSLog(@"my double tap");
}


#pragma mark - Action Handlers
- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Map Delegate
/**
 *  地图移动结束后调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    [self.view makeToast:[NSString stringWithFormat:@"did moved, newCenter = {%f, %f}", self.mapView.centerCoordinate.latitude,
                          self.mapView.centerCoordinate.longitude]];
}

/**
 *  地图缩放结束后调用此接口
 *
 *  @param mapView       地图view
 *  @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidZoomByUser:(BOOL)wasUserAction {
    [self.view makeToast:[NSString stringWithFormat:@"new zoomLevel = %.2f", self.mapView.zoomLevel]];
}

/**
 *  单击地图底图调用此接口
 *
 *  @param mapView    地图View
 *  @param coordinate 点击位置经纬度
 */
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.view makeToast:[NSString stringWithFormat:@"coordinate =  {%f, %f}", coordinate.latitude, coordinate.longitude]];
}

/**
 *  长按地图底图调用此接口
 *
 *  @param mapView    地图View
 *  @param coordinate 长按位置经纬度
 */
- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString *msg = [NSString stringWithFormat:@"coordinate =  {%f, %f}", coordinate.latitude, coordinate.longitude];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
}

@end

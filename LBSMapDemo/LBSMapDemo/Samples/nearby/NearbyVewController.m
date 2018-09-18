//
//  NearbyVewController.m
//  AMapSearchDemo
//
//  Created by xiaoming han on 15/9/7.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "NearbyVewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "UIView+Toast.h"

#define kUserID @"my-name-3"

@interface NearbyVewController ()<AMapNearbySearchManagerDelegate, AMapSearchDelegate, MAMapViewDelegate>
{
    AMapNearbySearchManager *_nearbyManager;
    MAMapView *_mapView;
    AMapSearchAPI *_search;
}

@end

@implementation NearbyVewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    _nearbyManager = [AMapNearbySearchManager sharedInstance];
    _nearbyManager.delegate = self;
    
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    
    UIButton *button1=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(10, 100, 70, 25);
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"auto" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(button1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(10, 150, 70, 25);
    button2.backgroundColor = [UIColor redColor];
    [button2 setTitle:@"upload" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(button2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button3.frame = CGRectMake(10, 200, 70, 25);
    button3.backgroundColor = [UIColor redColor];
    [button3 setTitle:@"clear" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(button3) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    UIButton *button4=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button4.frame = CGRectMake(10, 250, 70, 25);
    button4.backgroundColor = [UIColor redColor];
    [button4 setTitle:@"search" forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(button4) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_nearbyManager stopAutoUploadNearbyInfo];
    _nearbyManager.delegate = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)button1
{
    if (_nearbyManager.isAutoUploading)
    {
        [_nearbyManager stopAutoUploadNearbyInfo];
    }
    else
    {
        [_nearbyManager startAutoUploadNearbyInfo];
    }
    
}

- (void)button2
{
    if (_mapView.userLocation == nil)
    {
         [self.view makeToast:@"没有定位信息" duration:1.0];
    }
    
    AMapNearbyUploadInfo *info = [[AMapNearbyUploadInfo alloc] init];
    info.userID = kUserID;
    info.coordinate = _mapView.userLocation.coordinate;

    if ([_nearbyManager uploadNearbyInfo:info])
    {
        NSLog(@"YES");
    }
    else
    {
        NSLog(@"NO");
    }
}

- (void)button3
{
    [_nearbyManager clearUserInfoWithID:kUserID];
}

- (void)button4
{
    CLLocationCoordinate2D coor = _mapView.userLocation.coordinate;
    AMapNearbySearchRequest *request = [[AMapNearbySearchRequest alloc] init];
    request.center = [AMapGeoPoint locationWithLatitude:coor.latitude longitude:coor.longitude];
    
    [_search AMapNearbySearch:request];
    
}

#pragma mark -

- (AMapNearbyUploadInfo *)nearbyInfoForUploading:(AMapNearbySearchManager *)manager
{
    AMapNearbyUploadInfo *info = [[AMapNearbyUploadInfo alloc] init];
    info.userID = kUserID;
    info.coordinate = _mapView.userLocation.coordinate;
    
    return info;
}

- (void)onUserInfoClearedWithError:(NSError *)error
{
    if (error)
    {
        NSLog(@"clear error: %@", error);
    }
    else
    {
        NSLog(@"clear OK");
    }
}

- (void)onNearbyInfoUploadedWithError:(NSError *)error
{
    if (error)
    {
        [self.view makeToast:@"upload failed" duration:1.0];
        NSLog(@"upload error: %@", error);
    }
    else
    {
        [self.view makeToast:@"upload OK" duration:1.0];
    }
}

#pragma mark -
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@ - %@", error, [ErrorInfoUtility errorDescriptionWithCode:error.code]);
}


- (void)onNearbySearchDone:(AMapNearbySearchRequest *)request response:(AMapNearbySearchResponse *)response
{
    NSLog(@"nearby responst:%@", [response formattedDescription]);
    
    [_mapView removeAnnotations:_mapView.annotations];
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    for (AMapNearbyUserInfo *info in response.infos)
    {
        MAPointAnnotation *anno = [[MAPointAnnotation alloc] init];
        anno.title = [NSString stringWithFormat:@"%@(距离 %.1f 米)", info.userID, info.distance];
        anno.subtitle = [[NSDate dateWithTimeIntervalSince1970:info.updatetime] descriptionWithLocale:[NSLocale currentLocale]];
        
        anno.coordinate = CLLocationCoordinate2DMake(info.location.latitude, info.location.longitude);
        
        [annotations addObject:anno];
    }
    [_mapView addAnnotations:annotations];
    [_mapView showAnnotations:annotations animated:YES];

}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *poiIdentifier = @"nearbyPointIdentifier";
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:poiIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:poiIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        
        return poiAnnotationView;
    }
    
    return nil;
}


@end

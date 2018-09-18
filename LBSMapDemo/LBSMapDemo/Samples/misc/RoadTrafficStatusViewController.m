//
//  RoadTrafficStatusViewController.m
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 2017/4/13.
//  Copyright © 2017年 Autonavi. All rights reserved.
//

#import "RoadTrafficStatusViewController.h"
#import "CommonUtility.h"

@interface MARoadStatusPolyline : NSObject<MAOverlay>

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) MAPolyline *polyline;

@end

@implementation MARoadStatusPolyline
- (CLLocationCoordinate2D) coordinate {
    return [_polyline coordinate];
}

- (MAMapRect) boundingMapRect {
    return [_polyline boundingMapRect];
}
@end

@interface RoadTrafficStatusViewController ()<MAMapViewDelegate, AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapRoadTrafficSearchResponse *response;

@end

@implementation RoadTrafficStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    //self.mapView.showTraffic = YES;
    
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    [self searchRoadTrafficStatus];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchRoadTrafficStatus {
    AMapRoadTrafficSearchRequest *req = [[AMapRoadTrafficSearchRequest alloc] init];
    req.roadName = @"酒仙桥路";
    req.adcode = @"110000";
    req.requireExtension = YES;
    [self.search AMapRoadTrafficSearch:req];
}

#pragma mark - action handle
- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

/* 展示当前路线路况. */
- (void)presentCurrentRoadStatus
{
    MAMapRect bounds = MAMapRectZero;
    
    for(AMapTrafficRoad *road in self.response.trafficInfo.roads) {
        
        NSString *polylineStr = road.polyline;
        
        MAPolyline *polyLine = [CommonUtility polylineForCoordinateString:polylineStr];
        
        MARoadStatusPolyline *roadPolyLine = [[MARoadStatusPolyline alloc] init];
        roadPolyLine.polyline = polyLine;
        
        
        if(road.status == 1) {
            roadPolyLine.color = [UIColor greenColor];
        } else if(road.status == 2) {
            roadPolyLine.color = [UIColor yellowColor];
        } else if(road.status == 3) {
            roadPolyLine.color = [UIColor redColor];
        } else {
            roadPolyLine.color = [UIColor blueColor];
        }
        [self.mapView addOverlay:roadPolyLine];
        bounds = MAMapRectUnion(bounds, polyLine.boundingMapRect);
    }
    
    [self.mapView setVisibleMapRect:bounds animated:YES];
}

#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MARoadStatusPolyline class]])
    {
        MARoadStatusPolyline *roadPolyLine = (MARoadStatusPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:roadPolyLine.polyline];
        
        polylineRenderer.lineWidth = 6;
        
        polylineRenderer.strokeColor = roadPolyLine.color;
        
        return polylineRenderer;
    }
    
    return nil;
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@ - %@", error, [ErrorInfoUtility errorDescriptionWithCode:error.code]);
}

/* 道路路况查询回调. */
- (void)onRoadTrafficSearchDone:(AMapRoadTrafficSearchRequest *)request response:(AMapRoadTrafficSearchResponse *)response
{
    self.response = response;
    
    [self presentCurrentRoadStatus];
}


@end

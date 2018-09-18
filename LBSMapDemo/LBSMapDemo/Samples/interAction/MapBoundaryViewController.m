//
//  MapBoundaryViewController.m
//  MAMapKit
//
//  Created by shaobin on 16/8/30.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "MapBoundaryViewController.h"

@interface MapBoundaryViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) NSMutableArray *overlays;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, assign) MACoordinateRegion boundary;
@end

@implementation MapBoundaryViewController

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers
{
    NSLog(@"renderers :%@", renderers);
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 4.f;
        polylineView.strokeColor = [UIColor redColor];
        
        return polylineView;
    }
    
    return nil;
}

#pragma mark - Initialization

- (void)initBoundaryOverlay
{
    self.overlays = [NSMutableArray array];
    
    _boundary = //MACoordinateRegionMake(CLLocationCoordinate2DMake(40.4, 116.1), MACoordinateSpanMake(0.5, 0.2));
    MACoordinateRegionMake(CLLocationCoordinate2DMake(40, 116), MACoordinateSpanMake(2, 2));
    MAMapRect mapRect = MAMapRectForCoordinateRegion(_boundary);
    
    MAMapPoint points[5];
    points[0].x = mapRect.origin.x;
    points[0].y = mapRect.origin.y;
    
    points[1].x = mapRect.origin.x;
    points[1].y = mapRect.origin.y + mapRect.size.height;
    
    points[2].x = mapRect.origin.x + mapRect.size.width;
    points[2].y = mapRect.origin.y + mapRect.size.height;;
    
    points[3].x = mapRect.origin.x + mapRect.size.width;;
    points[3].y = mapRect.origin.y;
    
    points[4].x = mapRect.origin.x;
    points[4].y = mapRect.origin.y;
    
    MAPolyline * polyline = [MAPolyline polylineWithPoints:points count:5];
    [self.overlays addObject:polyline];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    [self initBoundaryOverlay];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.rotateEnabled = NO;
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    UIView *zoomPannelView = [self makeZoomPannelView];
    zoomPannelView.center = CGPointMake(self.view.bounds.size.width -  CGRectGetMidX(zoomPannelView.bounds) - 10,
                                        self.view.bounds.size.height -  CGRectGetMidY(zoomPannelView.bounds) - 10);
    
    zoomPannelView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:zoomPannelView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.mapView addOverlays:self.overlays];
    
    //注意，不要viewWillAppear里设置
    [self.mapView setLimitRegion:self.boundary];
}

- (UIView *)makeZoomPannelView
{
    UIView *ret = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 53, 98)];
    
    UIButton *incBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 53, 49)];
    [incBtn setImage:[UIImage imageNamed:@"increase"] forState:UIControlStateNormal];
    [incBtn sizeToFit];
    [incBtn addTarget:self action:@selector(zoomPlusAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *decBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 49, 53, 49)];
    [decBtn setImage:[UIImage imageNamed:@"decrease"] forState:UIControlStateNormal];
    [decBtn sizeToFit];
    [decBtn addTarget:self action:@selector(zoomMinusAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [ret addSubview:incBtn];
    [ret addSubview:decBtn];
    
    return ret;
}

#pragma mark - event handling
- (void)returnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)zoomPlusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom + 1) animated:YES];
}

- (void)zoomMinusAction
{
    CGFloat oldZoom = self.mapView.zoomLevel;
    [self.mapView setZoomLevel:(oldZoom - 1) animated:YES];
}
@end

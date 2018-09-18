//
//  GroundOverlayViewController.m
//  OfficialDemo3D
//
//  Created by songjian on 13-11-19.
//  Copyright © 2016 Amap. All rights reserved.
//

#import "GroundOverlayViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface GroundOverlayViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAGroundOverlay *groundOverlay;

@end

@implementation GroundOverlayViewController

#pragma mark - MAMapViewDelegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAGroundOverlay class]])
    {
        MAGroundOverlayRenderer *groundOverlayRenderer = [[MAGroundOverlayRenderer alloc] initWithGroundOverlay:overlay];
        
        return groundOverlayRenderer;
    }
    
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth    = 2.f;
        polylineRenderer.strokeColor  = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.9];
        
    
        return polylineRenderer;
    }
    
    return nil;
}

#pragma mark - initialization

- (void)initGroundOverlay {    
    MACoordinateBounds coordinateBounds = MACoordinateBoundsMake(CLLocationCoordinate2DMake(39.939577, 116.388331),
                                                                 CLLocationCoordinate2DMake(39.935029, 116.384377));
    
    self.groundOverlay = [MAGroundOverlay groundOverlayWithBounds:coordinateBounds icon:[UIImage imageNamed:@"GWF"]];
    self.groundOverlay.alpha = 0.5;
}

#pragma mark - Life Cycle

- (id)init {
    self = [super init];
    if (self) {
        [self initGroundOverlay];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    [self.mapView addOverlay:self.groundOverlay level:MAOverlayLevelAboveLabels];
    
    self.mapView.visibleMapRect = self.groundOverlay.boundingMapRect;
}

@end

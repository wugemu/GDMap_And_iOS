//
//  MultiPointOverlayViewController.m
//  MAMapKit
//
//  Created by hanxiaoming on 2017/4/13.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "MultiPointOverlayViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface MultiPointOverlayViewController ()<MAMapViewDelegate, MAMultiPointOverlayRendererDelegate>
{
    MAMultiPointOverlay *_overlay;
}

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation MultiPointOverlayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    [self initOverlay];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)initOverlay
{
    NSString *file = [[NSBundle mainBundle] pathForResource:@"10w" ofType:@"txt"];
    NSString *locationString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray *locations = [locationString componentsSeparatedByString:@"\n"];
    
    
    NSMutableArray *items = [NSMutableArray array];
    
    for (int i = 0; i < locations.count; ++i)
    {
        @autoreleasepool {
            MAMultiPointItem *item = [[MAMultiPointItem alloc] init];
            
            NSArray *coordinate = [locations[i] componentsSeparatedByString:@","];
            
            if (coordinate.count == 2)
            {
                item.coordinate = CLLocationCoordinate2DMake([coordinate[1] floatValue], [coordinate[0] floatValue]);
                
                [items addObject:item];
            }
        }
    }
    
    _overlay = [[MAMultiPointOverlay alloc] initWithMultiPointItems:items];
    [self.mapView addOverlay:_overlay];
    
    [self.mapView setVisibleMapRect:_overlay.boundingMapRect];
}

#pragma mark - Action Handlers

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAMultiPointOverlay class]])
    {
        MAMultiPointOverlayRenderer * renderer = [[MAMultiPointOverlayRenderer alloc] initWithMultiPointOverlay:overlay];
        
        renderer.icon = [UIImage imageNamed:@"marker_blue"];
        renderer.delegate = self;
        return renderer;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)overlayRenderers
{
    NSLog(@"overlayRenderers :%@", overlayRenderers);
}

#pragma mark - MAMultiPointOverlayRendererDelegate

- (void)multiPointOverlayRenderer:(MAMultiPointOverlayRenderer *)renderer didItemTapped:(MAMultiPointItem *)item
{
    NSLog(@"item :%@ <%f, %f>", item, item.coordinate.latitude, item.coordinate.longitude);
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotation:item];
}

@end

//
//  MapZoomByScreenAnchor.m
//  MAMapKit_3D_Demo
//
//  Created by 翁乐 on 18/10/2016.
//  Copyright © 2016 Autonavi. All rights reserved.
//

#import "MapZoomByScreenAnchor.h"
#import <MAMapKit/MAMapKit.h>

@interface MapZoomByScreenAnchor ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;


@end

@implementation MapZoomByScreenAnchor

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];

    
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MAPinAnnotationView *annotationView = [[MAPinAnnotationView alloc] init];
    annotationView.center = CGPointMake(0.2 * self.mapView.bounds.size.width, 0.3 * self.mapView.bounds.size.height);
    annotationView.pinColor = 3;
    
    [self.view addSubview:annotationView];
    
    MAMapStatus *mapstatus = [self.mapView getMapStatus];
    mapstatus.screenAnchor = CGPointMake(0.2,0.3);
    
    [self.mapView setMapStatus:mapstatus animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

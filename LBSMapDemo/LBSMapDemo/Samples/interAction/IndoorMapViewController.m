//
//  IndoorMapViewController.m
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 2017/6/27.
//  Copyright © 2017年 Autonavi. All rights reserved.
//

#import "IndoorMapViewController.h"

@interface IndoorMapViewController ()
@property (nonatomic, strong) MAMapView *mapView;
@end

@implementation IndoorMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.showsIndoorMap = YES;
    [self.view addSubview:self.mapView];
    
    self.mapView.centerCoordinate = CLLocationCoordinate2DMake(39.992856,116.468982);
    self.mapView.zoomLevel = 20;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"隐藏室内图"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(hideIndoor)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideIndoor {
    self.mapView.showsIndoorMap = NO;
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

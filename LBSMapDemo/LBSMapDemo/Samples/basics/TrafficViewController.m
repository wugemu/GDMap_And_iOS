//
//  TrafficViewController.m
//  Category_demo
//
//  Created by songjian on 13-3-21.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "TrafficViewController.h"

@interface TrafficViewController() <MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation TrafficViewController

#pragma mark - Xib click

//是否显示路况
- (IBAction)swtichShowTraffic:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    self.mapView.showTraffic = theSwitch.on;
}

//是否显示3D楼块
- (IBAction)swtichShowBuilding:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    self.mapView.showsBuildings = theSwitch.on;
}

//是否显示地图标注
- (IBAction)switchShowLabel:(id)sender {
    UISwitch *theSwitch = (UISwitch *)sender;
    self.mapView.showsLabels = theSwitch.on;
}

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
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    
}

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

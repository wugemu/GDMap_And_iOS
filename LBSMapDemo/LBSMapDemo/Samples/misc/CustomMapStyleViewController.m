//
//  CustomMapStyleViewController.m
//  MAMapKit_3D_Demo
//
//  Created by shaobin on 16/12/13.
//  Copyright © 2016年 Autonavi. All rights reserved.
//

#import "CustomMapStyleViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface CustomMapStyleViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView* mapView;
@property (nonatomic, strong) UIButton *changeStyleBtn;

@end

@implementation CustomMapStyleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(10, 50, 80, 25);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"Set" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(changeMapStyle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.changeStyleBtn = btn;
    
//    NSString *path = [NSString stringWithFormat:@"%@/style_json.json", [NSBundle mainBundle].bundlePath];
//    NSData *data = [NSData dataWithContentsOfFile:path];
//    [self.mapView setCustomMapStyle:data];
    
    NSString *path = [NSString stringWithFormat:@"%@/webExportedStyleData.data", [NSBundle mainBundle].bundlePath];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self.mapView setCustomMapStyleWithWebData:data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)changeMapStyle:(UIButton*)btn {
    if([[btn titleForState:UIControlStateNormal] isEqualToString:@"Cancel"]) {
        self.mapView.customMapStyleEnabled = NO;
        
        [btn setTitle:@"Set" forState:UIControlStateNormal];
    } else {
        self.mapView.customMapStyleEnabled = YES;
        [btn setTitle:@"Cancel" forState:UIControlStateNormal];
    }
}

#pragma mark - mapviewDelegate
- (void)mapInitComplete:(MAMapView *)mapView {
    [self changeMapStyle:self.changeStyleBtn];
}

@end

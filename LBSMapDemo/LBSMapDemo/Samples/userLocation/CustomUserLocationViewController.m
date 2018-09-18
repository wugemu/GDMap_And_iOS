//
//  CustomUserLocationViewController.m
//  officialDemo2D
//
//  Created by xiaoming han on 14-4-22.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "CustomUserLocationViewController.h"

@interface CustomUserLocationViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

@end

@implementation CustomUserLocationViewController

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
    
    
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    self.mapView.userLocation.title = @"您的位置在这里";
    
    MAUserLocationRepresentation *represent = [[MAUserLocationRepresentation alloc] init];
    represent.showsAccuracyRing = YES;
    represent.showsHeadingIndicator = YES;
    represent.fillColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.3];
    represent.strokeColor = [UIColor lightGrayColor];;
    represent.lineWidth = 2.f;
    represent.image = [UIImage imageNamed:@"userPosition"];
    [self.mapView updateUserLocationRepresentation:represent];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    MAAnnotationView *userLocationView = [self.mapView viewForAnnotation:self.mapView.userLocation];
    [UIView animateWithDuration:0.1 animations:^{
        
        double degree = self.mapView.userLocation.heading.trueHeading - self.mapView.rotationDegree;
        userLocationView.imageView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
    }];
}


#pragma mark - mapview delegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation)
    {
        MAAnnotationView *userLocationView = [mapView viewForAnnotation:mapView.userLocation];
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            userLocationView.imageView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
        }];
    }
}

#pragma mark - action handling

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

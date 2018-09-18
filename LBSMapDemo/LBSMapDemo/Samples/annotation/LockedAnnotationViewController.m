//
//  LockedAnnotationViewController.m
//  MAMapKit
//
//  Created by shaobin on 16/9/22.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "LockedAnnotationViewController.h"

@interface LockedAnnotationViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) NSMutableArray *annotations;

@end

@implementation LockedAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapView];
    self.mapView.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"固定"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(lockAction)];
    
    [self initAnnotations];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mapView addAnnotations:self.annotations];
}

- (void)initAnnotations {
    self.annotations = [NSMutableArray array];
    
    CLLocationCoordinate2D coordinates[2] = {{39.992520, 116.336170},
        {39.994520, 116.338170},
    };
    
    
    for (int i = 0; i < 2; ++i)
    {
        MAPointAnnotation *a = [[MAPointAnnotation alloc] init];
        a.coordinate = coordinates[i];
        [self.annotations addObject:a];
        
        if(i == 0) {
            a.lockedToScreen = YES;
            a.lockedScreenPoint = CGPointMake(100, 100);
        }
    }
}

#pragma mark - event handling
- (void)returnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)lockAction {
    MAPointAnnotation *an = self.annotations.firstObject;
    
    [an setLockedScreenPoint:CGPointMake(200, 200)];
    [an setLockedToScreen:YES];
}

#pragma mark - MAMapviewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIdentifier = @"pointReuseIdentifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIdentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIdentifier];
            
            annotationView.canShowCallout            = YES;
            annotationView.animatesDrop              = YES;
            annotationView.draggable                 = YES;
        }
        
        annotationView.pinColor = (annotation == self.annotations.firstObject ? MAPinAnnotationColorRed : MAPinAnnotationColorGreen);
        
        return annotationView;
    }
    
    return nil;
}

@end

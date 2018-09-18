//
//  TraceReplayOverlayViewController.m
//  MAMapKit
//
//  Created by shaobin on 2017/4/20.
//  Copyright © 2017年 Amap. All rights reserved.
//

#import "TraceReplayOverlayViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "MATraceReplayOverlay.h"
#import "MATraceReplayOverlayRender.h"

@interface TraceReplayOverlayViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MATraceReplayOverlay *overlay;

@end

@implementation TraceReplayOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    
    [self.view addSubview:self.mapView];
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:
                                             @"paused",
                                             @"go",
                                             @"reset",
                                             nil]];
    segmentedControl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventValueChanged];
    [segmentedControl sizeToFit];
    segmentedControl.center = CGPointMake(self.view.bounds.size.width / 2, segmentedControl.bounds.size.height / 2 + 35);
    [self.mapView addSubview:segmentedControl];
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *mainBunldePath = [[NSBundle mainBundle] bundlePath];
        NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@",mainBunldePath,@"TraceReplay.txt"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:fileFullPath]) {
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfFile:fileFullPath];
        NSError *err = nil;
        NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if(!arr) {
            NSLog(@"[AMap]: %@", err);
            return;
        }
        
        MAMapPoint *p = (MAMapPoint *)malloc(arr.count * sizeof(MAMapPoint));
        int index = 0;
        for(NSDictionary *dict in arr) {
            MAMapPoint point = MAMapPointForCoordinate(CLLocationCoordinate2DMake([[dict objectForKey:@"lat"] doubleValue], [[dict objectForKey:@"lon"] doubleValue]));
            
            p[index].x = point.x;
            p[index].y = point.y;
            index++;
        }
        
        
        self.overlay = [[MATraceReplayOverlay alloc] init];
        //        self.overlay.carImage = [UIImage imageNamed:@"userPosition"];
        self.overlay.enableAutoCarDirection = YES;
        self.overlay.speed = 1000000;
        [self.overlay setWithPoints:p count:index];
        
        if(p) {
            free(p);
        }
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.mapView addOverlay:weakSelf.overlay];
            [weakSelf.mapView showOverlays:@[weakSelf.overlay] animated:NO];
            
            [weakSelf.overlay addObserver:self forKeyPath:@"isPaused" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
        });
        
        //        [self.overlay prepareAsync:^{
        //            [weakSelf.overlay addObserver:self forKeyPath:@"isPaused" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:NULL];
        //            [weakSelf.mapView addOverlay:self.overlay];
        //            [weakSelf.mapView showOverlays:@[self.overlay] animated:NO];
        //        }];
    });
    
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (object == self.overlay && [keyPath isEqualToString:@"isPaused"]) {
        BOOL old = [change[NSKeyValueChangeOldKey] boolValue];
        BOOL new = [change[NSKeyValueChangeNewKey] boolValue];
        
        NSLog(@"old - %d, new - %d", old, new);
        
        self.mapView.isAllowDecreaseFrame = new;
    }
}

- (void)dealloc
{
    [self.overlay removeObserver:self forKeyPath:@"isPaused"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)onAction:(UISegmentedControl *)control {
    
    switch (control.selectedSegmentIndex) {
        case 0:
            self.overlay.isPaused = YES;
            break;
        case 1:
            self.overlay.isPaused = NO;
            break;
        case 2:
            [self.overlay reset];
            break;
        default:
            break;
    }
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers
{
    NSLog(@"renderers :%@", renderers);
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MATraceReplayOverlay class]])
    {
        MATraceReplayOverlayRenderer *ret = [[MATraceReplayOverlayRenderer alloc] initWithOverlay:overlay];
        ret.lineWidth = 4;
        ret.strokeColors = @[[[UIColor grayColor] colorWithAlphaComponent:0.6], [UIColor redColor]];
        return ret;
    }
    
    return nil;
}

@end

//
//  CustomPathVC.m
//  LBSMapDemo
//
//  Created by unispeed on 2018/3/12.
//  Copyright © 2018年 Ding. All rights reserved.
//

#import "CustomPathVC.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationManager.h>
#import <MAMapKit/MATraceManager.h>
#import "UIView+Toast.h"

@interface CustomPathVC ()<AMapSearchDelegate, MAMapViewDelegate,AMapLocationManagerDelegate>
{
    MAMapView *_mapView;
    AMapSearchAPI *_search;
    
    CLLocationCoordinate2D coords1[5];
    CLLocationCoordinate2D coords2[6];
    CLLocationCoordinate2D coords3[6];//五角星
    
    NSMutableArray * trackArr;
    NSMutableArray * locationArr;
    
    UILabel * resultLabel;
}

@property (nonatomic,strong)AMapLocationManager * locationManager;
@property (nonatomic,strong)MAAnimatedAnnotation* annotation;


@property (nonatomic, strong) NSMutableArray *origOverlays; //处理前的
@property (nonatomic, strong) NSMutableArray *processedOverlays; //处理后的

@property (nonatomic, strong) NSOperation *queryOperation;

@end

@implementation CustomPathVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    self.origOverlays = [NSMutableArray array];
    locationArr = [NSMutableArray array];
    trackArr = [NSMutableArray array];
    
    
    [self initCoordinates];
    
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _mapView.centerCoordinate = coords1[0];
    [_mapView setZoomLevel:16 animated:YES];
    //设置定位精度
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    //设置定位距离
    _mapView.distanceFilter = 10.0f;
    //普通样式
    _mapView.mapType = MAMapTypeStandard;
    [self.view addSubview:_mapView];
    
    
//    _search = [[AMapSearchAPI alloc] init];
//    _search.delegate = self;


    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 10;
    [self.locationManager setLocatingWithReGeocode:YES];

    
    

    //iOS 9（不包含iOS 9） 之前设置允许后台定位参数，保持不会被系统挂起
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];

    //iOS 9（包含iOS 9）之后新特性：将允许出现这种场景，同一app中多个locationmanager：一些只能在前台定位，另一些可在后台定位，并可随时禁止其后台定位。
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }


    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //   定位超时时间，最低2s，此处设置为2s
    self.locationManager.locationTimeout =10;
    //   逆地理请求超时时间，最低2s，此处设置为2s
    self.locationManager.reGeocodeTimeout = 10;


    //开始持续定位
    [self.locationManager startUpdatingLocation];
    
    
    
//    NSUserDefaults*userDefault = [NSUserDefaults standardUserDefaults];
//    id dataObj = [userDefault objectForKey:@"locationArr"];
//    if ([dataObj isKindOfClass:[NSArray class]]) {
//        NSLog(@"%@",dataObj);
//        NSArray * dataArr = (NSArray*)dataObj;
//        [self ProcessedTrace:dataArr];
//    }
    
    
//    NSArray * arr = @[@{@"lat":@"30.270827652325927",@"lon":@"120.10152976940367",@"angle":@"1.58501"},
//                            @{@"lat":@"30.272430654497178",@"lon":@"120.10139565895292",@"angle":@"1.58501"},
//                            @{@"lat":@"30.274764048499677",@"lon":@"120.10097129228018",@"angle":@"1.58501"},
//                            @{@"lat":@"30.275801791621806",@"lon":@"120.10151309850119",@"angle":@"1.58501"},
//                            @{@"lat":@"30.275889813971094",@"lon":@"120.1039109933605",@"angle":@"0.0"},
//                            @{@"lat":@"30.275889813971094",@"lon":@"120.1039109933605",@"angle":@"0.0"},
//                            @{@"lat":@"30.27591297773408",@"lon":@"120.10555786969564",@"angle":@"0.0"},
//                            @{@"lat":@"30.276672746130235",@"lon":@"120.10571880223654",@"angle":@"1.58501"},
//                            @{@"lat":@"30.277969898091147",@"lon":@"120.10564906480215",@"angle":@"1.58501"},
//                            @{@"lat":@"30.279016872526782",@"lon":@"120.10549886109732",@"angle":@"1.58501"},
//                            @{@"lat":@"30.2814724803",@"lon":@"120.1048779488",@"angle":@"1.58501"},
//                            @{@"lat":@"30.2816948392",@"lon":@"120.1052641869",@"angle":@"1.58501"},
//                            @{@"lat":@"30.2816763093",@"lon":@"120.1064872742",@"angle":@"0.0"},
//                            @{@"lat":@"30.2817133692",@"lon":@"120.1081180573",@"angle":@"0.0"},
//                            @{@"lat":@"30.2821580861",@"lon":@"120.1092338562",@"angle":@"1.58501"},
//                            @{@"lat":@"30.2843816403",@"lon":@"120.1086115837",@"angle":@"1.58501"}];

    
    
    //add overlay
//    MAPolyline *polyline1 = [MAPolyline polylineWithCoordinates:coords1 count:sizeof(coords1) / sizeof(coords1[0])];
//    MAPolyline *polyline2 = [MAPolyline polylineWithCoordinates:coords2 count:sizeof(coords2) / sizeof(coords2[0])];
//    MAPolyline *polyline3 = [MAPolyline polylineWithCoordinates:coords3 count:sizeof(coords3) / sizeof(coords3[0])];
//    [_mapView addOverlays:@[polyline1, polyline2, polyline3]];
    
//    MAPolyline *polyline1 = [MAPolyline polylineWithCoordinates:coords1 count:sizeof(coords1) / sizeof(coords1[0])];
//    [_mapView addOverlays:@[polyline1]];

    
    
    
//    Coords = malloc(sizeof(CLLocationCoordinate2D) * mArr2.count);
//    if(!Coords) {
//        return;
//    }
    
    
    MAAnimatedAnnotation *anno = [[MAAnimatedAnnotation alloc] init];
    anno.coordinate = coords1[0];
    self.annotation = anno;
    
    [_mapView addAnnotation:self.annotation];
    [self initButton];
    
    
    
    resultLabel = [[UILabel alloc] init];
    resultLabel.frame = CGRectMake(10, self.view.frame.size.height-140, self.view.frame.size.width-20, 20);
    resultLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    resultLabel.textColor = [UIColor whiteColor];
    resultLabel.font = [UIFont systemFontOfSize:12];
    resultLabel.numberOfLines = 10;
    [self.view addSubview:resultLabel];
    
}



- (void)clear {
    
//    [_mapView removeOverlays:self.origOverlays];
//    [self.origOverlays removeAllObjects];
}

- (MAMultiPolyline *)makePolyLineWith:(NSArray<MATracePoint*> *)tracePoints {
    if(tracePoints.count == 0) {
        return nil;
    }
    
    CLLocationCoordinate2D *pCoords = malloc(sizeof(CLLocationCoordinate2D) * tracePoints.count);
    if(!pCoords) {
        return nil;
    }
    
    for(int i = 0; i < tracePoints.count; ++i) {
        MATracePoint *p = [tracePoints objectAtIndex:i];
        CLLocationCoordinate2D *pCur = pCoords + i;
        pCur->latitude = p.latitude;
        pCur->longitude = p.longitude;
    }
    
    MAMultiPolyline *polyline = [MAMultiPolyline polylineWithCoordinates:pCoords count:tracePoints.count drawStyleIndexes:@[@10, @60]];
    
    if(pCoords) {
        free(pCoords);
    }
    
    return polyline;
}

- (void)addFullTrace:(NSArray<MATracePoint*> *)tracePoints toMapView:(MAMapView *)mapView{
    MAMultiPolyline *polyline = [self makePolyLineWith:tracePoints];
    if(!polyline) {
        return;
    }
    [mapView removeOverlays:self.origOverlays];
    [self.origOverlays removeAllObjects];
    
    [mapView setVisibleMapRect:MAMapRectInset(polyline.boundingMapRect, -1000, -1000)];
    
    [self.origOverlays addObject:polyline];
    [mapView addOverlays:self.origOverlays];
}

- (void)addSubTrace:(NSArray<MATracePoint*> *)tracePoints toMapView:(MAMapView *)mapView {
    MAMultiPolyline *polyline = [self makePolyLineWith:tracePoints];
    if(!polyline) {
        return;
    }
    
    MAMapRect visibleRect = [mapView visibleMapRect];
    if(!MAMapRectContainsRect(visibleRect, polyline.boundingMapRect)) {
        MAMapRect newRect = MAMapRectUnion(visibleRect, polyline.boundingMapRect);
        [mapView setVisibleMapRect:newRect];
    }
    
    [self.origOverlays addObject:polyline];
    
    [mapView addOverlay:polyline];
}




- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [_mapView setCompassImage:[UIImage imageNamed:@"compass"]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 开启定位
//    _mapView.showsUserLocation = YES;
//    _mapView.userTrackingMode = MAUserTrackingModeFollow;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [_mapView setCompassImage:nil];
    
//    [self.locationManager stopUpdatingLocation];
    
//    if (locationArr.count>0) {
//        NSUserDefaults*userDefault = [NSUserDefaults standardUserDefaults];
//        [userDefault setObject:locationArr forKey:@"locationArr"];
//        [userDefault synchronize];
//    }
    
}



- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)geocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    if (geocode)
    {
        NSLog(@"reGeocode:%@", geocode);
        
        
        if (locationArr.count>=6) {
            [locationArr removeAllObjects];
        }

        NSDictionary * dic = @{@"lat":[NSString stringWithFormat:@"%lf",location.coordinate.latitude],
                               @"lon":[NSString stringWithFormat:@"%lf",location.coordinate.longitude],
                               @"speed":[NSString stringWithFormat:@"%lf",location.speed],
                               @"loctime":[NSString stringWithFormat:@"%lf",[location.timestamp timeIntervalSince1970]*1000],
                               @"bearing":[NSString stringWithFormat:@"%lf",location.course]
                               };
        [locationArr addObject:dic];
        
        resultLabel.text = [NSString stringWithFormat:@"坐标数量：%lu 经纬度：%f，%f，地址：%@",(unsigned long)locationArr.count,location.coordinate.latitude, location.coordinate.longitude,geocode.formattedAddress];
        [resultLabel sizeToFit];
        
        if (locationArr.count>=6) {
            [self ProcessedTrace:locationArr];
        }
        
    }
}





-(void)ProcessedTrace:(NSArray*)arr;
{
    
    NSDictionary * dic1 = [arr firstObject];
    NSDictionary * dic2 = [arr lastObject];
    CGFloat time = (float)([dic2[@"loctime"] doubleValue]-[dic1[@"loctime"] doubleValue])/1000;
    
    
    AMapCoordinateType type = -1;
    
    NSMutableArray *mArr = [NSMutableArray array];
    NSMutableArray *mArr2 = [NSMutableArray arrayWithCapacity:mArr.count];
    for(NSDictionary *dict in arr) {
        MATraceLocation *loc = [[MATraceLocation alloc] init];
        loc.loc = CLLocationCoordinate2DMake([[dict objectForKey:@"lat"] doubleValue], [[dict objectForKey:@"lon"] doubleValue]);
        double speed = [[dict objectForKey:@"speed"] doubleValue];
        loc.speed = speed * 3.6; //m/s  转 km/h
        loc.time = [[dict objectForKey:@"loctime"] doubleValue];
        loc.angle = [[dict objectForKey:@"bearing"] doubleValue];
        [mArr addObject:loc];
        
        MATracePoint *p = [[MATracePoint alloc] init];
        if(type <= AMapCoordinateTypeGPS) {
            //坐标转换
            CLLocationCoordinate2D l = AMapCoordinateConvert(loc.loc, type);
            p.latitude = l.latitude;
            p.longitude = l.longitude;
        } else {
            p.latitude = loc.loc.latitude;
            p.longitude = loc.loc.longitude;
        }
        
        if (fabs(p.longitude - 0) < 0.0001 && fabs(p.latitude - 0) < 0.0001) {
            continue;
        }
        
        [mArr2 addObject:p];
    }
    //    [self addSubTrace:mArr2 toMapView:_mapView];
    
    
    MATraceManager *temp = [[MATraceManager alloc] init];
    
    __weak typeof(self) weakSelf = self;
    NSOperation *op = [temp queryProcessedTraceWith:mArr type:-1 processingCallback:^(int index, NSArray<MATracePoint *> *points) {
//        [weakSelf addSubTrace:points toMapView:_mapView];
    }  finishCallback:^(NSArray<MATracePoint *> *points, double distance) {
        NSLog(@"距离:%.0f米",distance);
        weakSelf.queryOperation = nil;
        
        NSMutableArray * finishArr = [NSMutableArray array];
        if (trackArr.count>0) {
            [finishArr addObject:[trackArr lastObject]];
        }
        [trackArr addObjectsFromArray:points];
        
        [finishArr addObjectsFromArray:points];
        
        [weakSelf addFullTrace:trackArr toMapView:_mapView];
        
        int count = (int)finishArr.count;
        CLLocationCoordinate2D Coords[count];
        for(int i = 0; i < finishArr.count; ++i) {
            MATracePoint *p = [finishArr objectAtIndex:i];
            Coords[i].latitude = p.latitude;
            Coords[i].longitude = p.longitude;
        }
        
        self.annotation.coordinate = Coords[0];
        MAAnimatedAnnotation *anno = self.annotation;
        [anno addMoveAnimationWithKeyCoordinates:Coords count:count withDuration:time withName:nil completeCallback:^(BOOL isFinished) {
        }];
        
        
    } failedCallback:^(int errorCode, NSString *errorDesc) {
        NSLog(@"Error: %@", errorDesc);
        weakSelf.queryOperation = nil;
    }];
    
    self.queryOperation = op;
    
    
    
}









- (void)initCoordinates {
    
    
    
    
    
    ///1
    coords1[0].latitude = 30.270827652325927;
    coords1[0].longitude = 120.10152976940367;

    coords1[1].latitude = 30.272430654497178;
    coords1[1].longitude = 120.10139565895292;

    coords1[2].latitude = 30.274764048499677;
    coords1[2].longitude = 120.10097129228018;

    coords1[3].latitude = 30.275801791621806;
    coords1[3].longitude = 120.10151309850119;

    coords1[4].latitude = 30.275889813971094;
    coords1[4].longitude = 120.1039109933605;

//    ///2
//    coords2[0].latitude = 30.275889813971094;
//    coords2[0].longitude = 120.1039109933605;
//
//    coords2[1].latitude = 30.27591297773408;
//    coords2[1].longitude = 120.10555786969564;
//
//    coords2[2].latitude = 30.276672746130235;
//    coords2[2].longitude = 120.10571880223654;
//
//    coords2[3].latitude = 30.277969898091147;
//    coords2[3].longitude = 120.10564906480215;
//
//    coords2[4].latitude = 30.279016872526782;
//    coords2[4].longitude = 120.10549886109732;
//
//    coords2[5].latitude = 30.2814724803;
//    coords2[5].longitude = 120.1048779488;
//
//
//    ///3
//    coords3[0].latitude = 30.2814724803;
//    coords3[0].longitude = 120.1048779488;
//
//    coords3[1].latitude = 30.2816948392;
//    coords3[1].longitude = 120.1052641869;
//
//    coords3[2].latitude = 30.2816763093;
//    coords3[2].longitude = 120.1064872742;
//
//    coords3[3].latitude = 30.2817133692;
//    coords3[3].longitude = 120.1081180573;
//
//    coords3[4].latitude = 30.2821580861;
//    coords3[4].longitude = 120.1092338562;
//
//    coords3[5].latitude = 30.2843816403;
//    coords3[5].longitude = 120.1086115837;
    
//    ///3
//    [self generateStarPoints:coords3 pointsCount:10 atCenter:CLLocationCoordinate2DMake(30.281757957243556, 120.1048658597698)];//生成多角星的坐标
//
//    coords2[5] = coords3[0];
}

/*!
 @brief  生成多角星坐标
 @param coordinates 输出的多角星坐标数组指针。内存需在外申请，方法内不释放，多角星坐标结果输出。
 @param pointsCount 输出的多角星坐标数组元素个数。
 @param starCenter  多角星的中心点位置。
 */
- (void)generateStarPoints:(CLLocationCoordinate2D *)coordinates pointsCount:(NSUInteger)pointsCount atCenter:(CLLocationCoordinate2D)starCenter
{
#define STAR_RADIUS 0.05
#define PI 3.1415926
    NSUInteger starRaysCount = pointsCount / 2;
    for (int i =0; i<starRaysCount; i++)
    {
        float angle = 2.f*i/starRaysCount*PI;
        int index = 2 * i;
        coordinates[index].latitude = STAR_RADIUS* sin(angle) + starCenter.latitude;
        coordinates[index].longitude = STAR_RADIUS* cos(angle) + starCenter.longitude;
        
        index++;
        angle = angle + (float)1.f/starRaysCount*PI;
        coordinates[index].latitude = STAR_RADIUS/2.f* sin(angle) + starCenter.latitude;
        coordinates[index].longitude = STAR_RADIUS/2.f* cos(angle) + starCenter.longitude;
    }
}



- (void)initButton
{
    UIButton *button1=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(10, 50, 70,25);
    button1.backgroundColor = [UIColor redColor];
    [button1 setTitle:@"Go" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(button1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(10, 100,70,25);
    button2.backgroundColor = [UIColor redColor];
    [button2 setTitle:@"Stop" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(button2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
}

- (void)button1 {
    
    MAAnimatedAnnotation *anno = self.annotation;
    [anno addMoveAnimationWithKeyCoordinates:coords1 count:sizeof(coords1) / sizeof(coords1[0]) withDuration:15 withName:nil completeCallback:^(BOOL isFinished) {
        
//        MAPolyline *polyline2 = [MAPolyline polylineWithCoordinates:coords2 count:sizeof(coords2) / sizeof(coords2[0])];
//        [_mapView addOverlays:@[polyline2]];
    }];
    
//    [anno addMoveAnimationWithKeyCoordinates:coords2 count:sizeof(coords2) / sizeof(coords2[0]) withDuration:5 withName:nil completeCallback:^(BOOL isFinished) {
//        MAPolyline *polyline3 = [MAPolyline polylineWithCoordinates:coords3 count:sizeof(coords3) / sizeof(coords3[0])];\
//        [_mapView addOverlays:@[polyline3]];
//    }];
//
//    [anno addMoveAnimationWithKeyCoordinates:coords3 count:sizeof(coords3) / sizeof(coords3[0]) withDuration:5 withName:nil completeCallback:^(BOOL isFinished) {
//    }];
}

- (void)button2 {
    for(MAAnnotationMoveAnimation *animation in [self.annotation allMoveAnimations]) {
        [animation cancel];
    }
    
    self.annotation.movingDirection = 0;
    self.annotation.coordinate = coords1[0];
}

#pragma mark - mapview delegate
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth    = 8.f;
        polylineRenderer.strokeImage = [UIImage imageNamed:@"arrowTexture"];
        return polylineRenderer;
        
    } else if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 16.f;
        polylineView.strokeImage = [UIImage imageNamed:@"custtexture"];
        
        return polylineView;
    }
    
    return nil;
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        NSString *pointReuseIndetifier = @"myReuseIndetifier";
        MAAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:pointReuseIndetifier];
            
            UIImage * imge = [UIImage imageNamed:@"carIcon"];
            annotationView.image = imge;
        }
        
        annotationView.canShowCallout               = YES;
        annotationView.draggable                    = NO;
        annotationView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
    
    return nil;
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

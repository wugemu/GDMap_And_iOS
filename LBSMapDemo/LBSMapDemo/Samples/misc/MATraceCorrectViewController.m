//
//  MATraceCorrectViewController.m
//  MAMapKit
//
//  Created by shaobin on 16/9/2.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "MATraceCorrectViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <MAMapKit/MATraceManager.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface MATraceCorrectViewController ()<MAMapViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MAMapView *mapView1;
@property (nonatomic, strong) MAMapView *mapView2;
@property (nonatomic, strong) NSMutableArray *origOverlays; //处理前的
@property (nonatomic, strong) NSMutableArray *processedOverlays; //处理后的

@property (nonatomic, strong) NSOperation *queryOperation;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *testInputFiles;
@property (nonatomic, strong) NSString *inputFilesPath;
@property (nonatomic, strong) NSString *seletedInputFile;

@property (nonatomic, strong) UIButton *queryButton;
@property (nonatomic, strong) NSArray *debugColors;

@property (nonatomic, strong) UILabel *resultLabel;

@end

@implementation MATraceCorrectViewController

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers
{
    NSLog(@"renderers :%@", renderers);
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAPolylineRenderer *polylineView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
     
        if(mapView == self.mapView1) {
            polylineView.lineWidth   = 8.f;
            polylineView.strokeColor = [UIColor blueColor];
        } else {
            polylineView.lineWidth   = 16.f;
            polylineView.strokeImage = [UIImage imageNamed:@"custtexture"];
        }
        
        return polylineView;
    }
    
    return nil;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.debugColors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor],];
    
    self.origOverlays = [NSMutableArray array];
    self.processedOverlays = [NSMutableArray array];
    self.resultLabel = [[UILabel alloc] init];
    self.resultLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.resultLabel.textColor = [UIColor whiteColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnAction)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemAction)];
    
    _mapView1 = [[MAMapView alloc] initWithFrame:CGRectMake(0, 5, self.view.bounds.size.width, self.view.bounds.size.height / 2.0)];
    _mapView1.delegate = self;
    [self.view addSubview:_mapView1];
    
    _mapView2 = [[MAMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView1.frame) + 5, self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(_mapView1.frame) - 10)];
    _mapView2.delegate = self;
    [self.view addSubview:_mapView2];
    
    UIView *zoomPannelView = [self makeControlPannelView];
    zoomPannelView.center = CGPointMake(self.view.bounds.size.width -  CGRectGetMidX(zoomPannelView.bounds) - 10,
                                        self.view.bounds.size.height -  CGRectGetMidY(zoomPannelView.bounds) - 10);
    
    zoomPannelView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:zoomPannelView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    _mapView1.frame = CGRectMake(0, 0, self.view.bounds.size.width, (self.view.bounds.size.height - 10) / 2.0);
    _mapView2.frame = CGRectMake(0, CGRectGetMaxY(_mapView1.frame) + 10, self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMaxY(_mapView1.frame) - 10);
}

#pragma mark - action handling
- (void)rightBarItemAction {
    if(!self.tableView) {
        self.inputFilesPath = [NSString stringWithFormat:@"%@/traceRecordData" ,[NSBundle mainBundle].bundlePath];
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.inputFilesPath error:nil];
        self.testInputFiles = files;
        
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.tableView.delegate   = self;
        self.tableView.dataSource = self;
        
        [self.view addSubview:self.tableView];
    }
    
    [self.tableView reloadData];
    [self.tableView setHidden:NO];
}

- (void)returnAction {
    if(self.tableView && !self.tableView.isHidden) {
        [self.tableView setHidden:YES];
        return;
    }
    
    [self cancelAction];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)queryAction {
    self.resultLabel.text = nil;
    [self.resultLabel setHidden:YES];
    
    if(self.seletedInputFile.length == 0) {
        return;
    }
    
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@",self.inputFilesPath,self.seletedInputFile];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileFullPath]) {
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:fileFullPath];
    NSMutableData *mData = [[NSMutableData alloc] init];
    NSString *head = @"[";
    NSString *tail = @"]";
    
    [mData appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
    [mData appendData:data];
    [mData appendData:[tail dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSError *err = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:mData options:0 error:&err];
    if(!arr) {
        NSLog(@"[AMap]: %@", err);
        return;
    }
    
    AMapCoordinateType type = -1;
    if([self.seletedInputFile hasPrefix:@"Baidu"]) {
        type = AMapCoordinateTypeBaidu;
    } else if([self.seletedInputFile hasPrefix:@"GPS"]) {
        type = AMapCoordinateTypeGPS;
    }
    
    NSMutableArray *mArr = [NSMutableArray array];
    NSMutableArray *mArr2 = [NSMutableArray arrayWithCapacity:mArr.count];
    for(NSDictionary *dict in arr) {
        MATraceLocation *loc = [[MATraceLocation alloc] init];
        loc.loc = CLLocationCoordinate2DMake([[dict objectForKey:@"lat"] doubleValue], [[dict objectForKey:@"lon"] doubleValue]);
        double speed = [[dict objectForKey:@"speed"] doubleValue];
        loc.speed = speed * 3.6; //m/s  转 km/h
        loc.time = [[dict objectForKey:@"loctime"] doubleValue];
        loc.angle = [[dict objectForKey:@"bearing"] doubleValue];;
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
    
    MATraceManager *temp = [[MATraceManager alloc] init];

    [self clear];
    [self addFullTrace:mArr2 toMapView:self.mapView1];
    
    __weak typeof(self) weakSelf = self;
    NSOperation *op = [temp queryProcessedTraceWith:mArr type:type processingCallback:^(int index, NSArray<MATracePoint *> *points) {
        [weakSelf addSubTrace:points toMapView:weakSelf.mapView2];
    }  finishCallback:^(NSArray<MATracePoint *> *points, double distance) {
        weakSelf.queryOperation = nil;
        [weakSelf addFullTrace:points toMapView:weakSelf.mapView2];
        
        [weakSelf.resultLabel setHidden:NO];
        weakSelf.resultLabel.text = [NSString stringWithFormat:@"距离:%.0f米", distance];
        [weakSelf.resultLabel sizeToFit];
        weakSelf.resultLabel.center = CGPointMake(CGRectGetMidX(weakSelf.resultLabel.bounds), weakSelf.mapView2.bounds.size.height -  CGRectGetMidY(weakSelf.resultLabel.bounds));
        if(!weakSelf.resultLabel.superview) {
            [weakSelf.mapView2 addSubview:weakSelf.resultLabel];
        }
    } failedCallback:^(int errorCode, NSString *errorDesc) {
        NSLog(@"Error: %@", errorDesc);
        weakSelf.queryOperation = nil;
    }];
    
    self.queryOperation = op;
}

- (void)cancelAction {
    if(self.queryOperation) {
        [self.queryOperation cancel];
        
        self.queryOperation = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.testInputFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mainCellIdentifier = @"mainCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainCellIdentifier];
    }
    
    cell.textLabel.text = self.testInputFiles[indexPath.row];
    if([cell.textLabel.text isEqualToString:self.seletedInputFile]) {
        cell.textLabel.textColor = [UIColor redColor];
    } else {
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.seletedInputFile = [self.testInputFiles objectAtIndex:indexPath.row];
    [self.queryButton setEnabled:(self.seletedInputFile.length > 0)];
    
    [tableView setHidden:YES];
}

#pragma mark - utils
- (UIView *)makeControlPannelView
{
    UIView *ret = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 53, 98)];
    ret.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    UIButton *incBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 53, 49)];
    [incBtn setTitle:@"query" forState:UIControlStateNormal];
    [incBtn setTitle:@"query" forState:UIControlStateDisabled];
    [incBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [incBtn addTarget:self action:@selector(queryAction) forControlEvents:UIControlEventTouchUpInside];
    self.queryButton = incBtn;
    [self.queryButton setEnabled:NO];
    
    UIButton *decBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 49, 53, 49)];
    [decBtn setTitle:@"cancel" forState:UIControlStateNormal];
    [decBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    [ret addSubview:incBtn];
    [ret addSubview:decBtn];
    
    return ret;
}

- (void)clear {
    [self.mapView1 removeOverlays:self.origOverlays];
    [self.mapView2 removeOverlays:self.processedOverlays];
    
    [self.origOverlays removeAllObjects];
    [self.processedOverlays removeAllObjects];
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
    
    if(mapView == self.mapView2) {
        [mapView removeOverlays:self.processedOverlays];
        [self.processedOverlays removeAllObjects];
    } else {
        [mapView removeOverlays:self.origOverlays];
        [self.origOverlays removeAllObjects];
    }
    
    [mapView setVisibleMapRect:MAMapRectInset(polyline.boundingMapRect, -1000, -1000)];

    if(mapView == self.mapView2) {
        [self.processedOverlays addObject:polyline];
        [mapView addOverlays:self.processedOverlays];
    } else {
        [self.origOverlays addObject:polyline];
        [mapView addOverlays:self.origOverlays];
    }
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
    
    if(mapView == self.mapView2) {
        [self.processedOverlays addObject:polyline];
    } else {
        [self.origOverlays addObject:polyline];
    }
    
    [mapView addOverlay:polyline];
}

@end

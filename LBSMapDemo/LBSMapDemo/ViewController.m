//
//  ViewController.m
//  LBSMapDemo
//
//  Created by unispeed on 2018/3/7.
//  Copyright © 2018年 Ding. All rights reserved.
//

#import "ViewController.h"
#define MainViewControllerTitle @"高德地图API-3D"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView * _mainTableView;
    NSArray     * _titles;
    NSArray     * _className;
}

@end

@implementation ViewController


#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *rows = [[_titles objectAtIndex:indexPath.section] allValues].firstObject;
    NSString *className = [[rows objectAtIndex:indexPath.row] allValues].firstObject;
    NSString *title = [[rows objectAtIndex:indexPath.row] allKeys].firstObject;
    
    BOOL handled = NO;
    if(self.delegate) {
        handled = [self.delegate viewController:self itemSelected:className title:title];
    }
    
    if(handled) {
        return;
    }
    
    UIViewController *subViewController = [[NSClassFromString(className) alloc] init];
    NSString *xibBundlePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",className] ofType:@"xib"];
    if (xibBundlePath.length) {
        subViewController = [[NSClassFromString(className) alloc] initWithNibName:className bundle:nil];
    }
    subViewController.title = title;
    
    [self.navigationController pushViewController:subViewController animated:YES];
}

#pragma mark - tableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_titles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[_titles objectAtIndex:section] allValues].firstObject count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *mainCellIdentifier = @"com.autonavi.mainCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainCellIdentifier];
    NSArray *rows = [[_titles objectAtIndex:indexPath.section] allValues].firstObject;
    NSString *className = [[rows objectAtIndex:indexPath.row] allValues].firstObject;
    NSString *title = [[rows objectAtIndex:indexPath.row] allKeys].firstObject;
    if(self.delegate) {
        className = [self.delegate viewController:self displayTileOf:className];
        className = [className componentsSeparatedByString:@"."].lastObject;
    }
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:mainCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.lineBreakMode = NSLineBreakByCharWrapping;
        cell.detailTextLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.detailTextLabel.text = className;
    cell.textLabel.text = title;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainTableView.bounds.size.width, 40)];
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor darkGrayColor];
    label.text = [[_titles objectAtIndex:section] allKeys].firstObject;
    label.numberOfLines = 1;
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = 15;
    frame.origin.y = header.bounds.size.height - frame.size.height;
    label.frame = frame;
    [header addSubview:label];
    return header;
}
#pragma mark - init
- (void)initTitles
{
    ///主页面标签title
//    _titles = @[@{@"创建地图":@[
//                          @{@"显示定位蓝点(默认样式)":@"UserLocationViewController"},
//                          @{@"显示定位蓝点(自定义样式)":@"CustomUserLocationViewController"},
//                          @{@"显示定位蓝点(定位箭头旋转效果)":@"CustomUserLoactionViewController2"},
//                          @{@"显示室内地图":@"IndoorMapViewController"},
//                          @{@"切换地图图层":@"MapTypeViewController"},
//                          @{@"使用离线地图":@"OfflineViewController"}
//                          ]
//                  },
//                @{@"与地图交互":@[
//                          @{@"控件交互":@"AddControlsViewController"},
//                          @{@"手势交互":@"OperateMapViewController"},
//                          @{@"方法交互(改变地图缩放级别)":@"ChangeZoomViewController"},
//                          @{@"方法交互(改变地图中心点)":@"ChangeCenterViewController"},
//                          @{@"方法交互(限制地图的显示范围)":@"MapBoundaryViewController"},
//                          @{@"地图截屏功能":@"ScreenshotViewController"},
//                          @{@"地图POI点击功能":@"TouchPoiViewController"},
//                          @{@"地图动画效果":@"CoreAnimationViewController"},
//                          @{@"设置地图基于指定锚点进行缩放":@"MapZoomByScreenAnchor"}]
//                  },
//
//                @{@"在地图上绘制":@[
//                          @{@"绘制点标记":@"AnnotationViewController"},
//                          @{@"绘制点标记(自定义)":@"CustomAnnotationViewController"},
//                          @{@"绘制点标记(动画)":@"AnimatedAnnotationViewController"},
//                          @{@"绘制点标记(固定屏幕点)":@"LockedAnnotationViewController"},
//                          @{@"绘制折线":@"LinesOverlayViewController"},
//                          @{@"绘制面(圆形)":@"CircleOverlayViewController"},
//                          @{@"绘制面(矩形)":@"PolygonOverlayViewController"},
//                          @{@"轨迹纠偏":@"MATraceCorrectViewController"},
//                          @{@"点平滑移动":@"MovingAnnotationViewController"},
//                          @{@"自定义地图":@"CustomMapStyleViewController"},
//                          @{@"绘制海量点图层":@"MultiPointOverlayViewController"},
//                          @{@"多彩线":@"ColoredLinesOverlayViewController"},
//                          @{@"大地曲线":@"GeodesicViewController"},
//                          @{@"跑步轨迹":@"RunningLineViewController"},
//                          @{@"热力图":@"HeatMapTileOverlayViewController"},
//                          @{@"纹理线":@"TexturedLineOverlayViewController"},
//                          @{@"自定义overlay":@"CustomOverlayViewController"},
//                          @{@"OpenGl绘制":@"StereoOverlayViewController"},
//                          @{@"TileOverlay":@"TileOverlayViewController"},
//                          @{@"GroundOverlay":@"GroundOverlayViewController"},
//                          @{@"海量点轨迹回放":@"TraceReplayOverlayViewController"}
//                          ]
//                  },
//                @{@"获取地图数据":@[
//                          @{@"获取POI数据(根据关键字检索POI)":@"PoiSearchPerKeywordController"},
//                          @{@"获取POI数据(根据id检索POI)":@"PoiSearchPerIdController"},
//                          @{@"获取POI数据(检索指定位置周边的POI)":@"PoiSearchNearByController"},
//                          @{@"获取POI数据(检索指定范围内的POI)":@"PoiSearchWithInPolygonController"},
//                          @{@"获取POI数据(根据输入自动提示)":@"TipViewController"},
//                          @{@"获取地址描述数据(地址转坐标)":@"GeoViewController"},
//                          @{@"获取地址描述数据(坐标转地址)":@"InvertGeoViewController"},
//                          @{@"获取行政区划数据":@"DistrictViewController"},
//                          @{@"获取公交数据(线路查询)":@"BusLineViewController"},
//                          @{@"获取公交数据(站点查询)":@"BusStopViewController"},
//                          @{@"获取天气数据":@"WeatherViewController"},
//                          @{@"获取业务数据(检索指定位置周边的POI)":@"CloudPOIAroundSearchViewController"},
//                          @{@"获取业务数据(根据id检索POI)":@"CloudPOIIDSearchViewController"},
//                          @{@"获取业务数据(根据关键字检索某一地区POI)":@"CloudPOILocalSearchViewController"},
//                          @{@"获取业务数据(检索指定范围内的POI)":@"CloudPOIPolygonSearchViewController"},
//                          @{@"获取交通态势信息":@"RoadTrafficStatusViewController"},
//                          ]
//                  },
//                @{@"出行线路规划":@[
//                          @{@"驾车出行路线规划":@"RoutePlanDriveViewController"},
//                          @{@"步行出行路线规划":@"RoutePlanWalkViewController"},
//                          @{@"公交出行路线规划":@"RoutePlanBusViewController"},
//                          @{@"骑行出行路线规划":@"RoutePlanRideViewController"},
//                          @{@"公交出行路线规划(跨城)":@"RoutePlanBusCrossCityViewController"}
//                          ]
//                  },
//                @{@"地图计算工具":@[
//                          @{@"坐标转换":@"CooridinateSystemConvertController"},
//                          @{@"两点间距离计算":@"DistanceCalculateViewController"},
//                          @{@"点与线的距离计算":@"DistanceCalculateViewController2"},
//                          @{@"判断点是否在多边形内":@"InsideTestViewController"}
//                          ]
//                  },
//                @{@"短串分享":@[
//                          @{@"位置分享":@"LocationShareViewController"},
//                          @{@"路径规划分享":@"RouteShareViewController"},
//                          @{@"POI分享":@"POIShareViewController"},
//                          @{@"导航分享":@"NaviShareViewController"}
//                          ]
//                  },
//                @{@"其他":@[@{@"周边搜索":@"NearbyVewController"},@{@"自定义Demo":@"CustomPathVC"}]},
//                ];
    
    _titles = @[@{@"其他":@[@{@"自定义Demo":@"CustomPathVC"}]}
                ];
    
    if(self.delegate) {
        NSMutableArray *titles = [NSMutableArray array];
        for(int section = 0; section < _titles.count; ++section) {
            NSDictionary *sectionItem = [_titles objectAtIndex:section];
            NSString *titleKey = [sectionItem allKeys].firstObject;
            NSArray *rows = [sectionItem allValues].firstObject;
            NSMutableArray *arr = [NSMutableArray array];
            for(int row = 0; row < rows.count; ++row) {
                NSDictionary *rowItem = [rows objectAtIndex:row];
                NSString *className = [rowItem allValues].firstObject;
                if([self.delegate viewController:self displayTileOf:className]) {
                    [arr addObject:rowItem];
                }
            }
            
            if(arr.count > 0) {
                [titles addObject:@{titleKey:arr}];
            }
        }
        
        _titles = titles;
    }
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = MainViewControllerTitle;
    
    [self initTitles];
    
    _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _mainTableView.sectionHeaderHeight = 10;
    _mainTableView.sectionFooterHeight = 0;
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    
    [self.view addSubview:_mainTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

package com.bill.logisticsclouddemo;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.amap.api.fence.GeoFence;
import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.location.DPoint;
import com.amap.api.maps.AMap;
import com.amap.api.maps.AMapOptions;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.MapView;
import com.amap.api.maps.UiSettings;
import com.amap.api.maps.model.BitmapDescriptorFactory;
import com.amap.api.maps.model.CameraPosition;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.Marker;
import com.amap.api.maps.model.Poi;
import com.amap.api.maps.model.Polyline;
import com.amap.api.maps.utils.overlay.SmoothMoveMarker;
import com.amap.api.navi.AMapNavi;
import com.amap.api.navi.AmapNaviPage;
import com.amap.api.navi.AmapNaviParams;
import com.amap.api.navi.AmapNaviType;
import com.amap.api.navi.INaviInfoCallback;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.route.BusRouteResult;
import com.amap.api.services.route.DrivePath;
import com.amap.api.services.route.DriveRouteResult;
import com.amap.api.services.route.RideRouteResult;
import com.amap.api.services.route.RouteSearch;
import com.amap.api.services.route.WalkRouteResult;
import com.amap.api.trace.TraceListener;
import com.bill.logisticsclouddemo.amap.AMapNaviInfoCallbackAdapter;
import com.bill.logisticsclouddemo.amap.AMapUtil;
import com.bill.logisticsclouddemo.amap.MyTraceClient;
import com.bill.logisticsclouddemo.amap.routeSearch.DrivingRouteOverlay;
import com.bill.logisticsclouddemo.amap.MyGeoFenceClient;
import com.bill.logisticsclouddemo.amap.routeSearch.OnRouteSearchAdapter;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class MainActivity extends AppCompatActivity {

    //LinearLayout content;
    MapView mapView;
    AMap aMap;
    private SmoothMoveMarker moveMarker;    // 当前定位点图标
    private float moveSpeed;       // 当前定位点速度
    private float moveDirection;   // 当前点的方向
    private LatLng moveLatlng;      // 当前点的坐标
    private double mEndLatitude = 30.267384d,mEndLongitude = 120.092691d;


    private MyGeoFenceClient myGeoFenceClient;
    private MyTraceClient myTraceClient;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        //content = (LinearLayout) findViewById(R.id.content);
        mapView = (MapView) findViewById(R.id.map);
        mapView.onCreate(savedInstanceState);
        myTraceClient = FarmApplication.getInstance().getMyTraceClient();
        // 开启定位
        FarmApplication.getInstance().getAmapLocationClient().start(mapLocationListener2);
        // 初始化地图
        initAMap();
        // 开启围栏
        initGeoFence();
        // 开启导航语音
        AMapNavi.getInstance(this).setUseInnerVoice(true);
    }

    private void initAMap() {
        // initAMapOptions();

        aMap = mapView.getMap();
        UiSettings mapUiSettings = aMap.getUiSettings();
        mapUiSettings.setZoomGesturesEnabled(true); // 可以通过手势缩放地图
        mapUiSettings.setScrollGesturesEnabled(true);   // 可以通过手势移动地图
        mapUiSettings.setTiltGesturesEnabled(false);    // 禁止通过手势倾斜地图
        mapUiSettings.setRotateGesturesEnabled(false);  // 禁止通过手势旋转
        aMap.animateCamera(CameraUpdateFactory.newCameraPosition(new CameraPosition(new LatLng(mEndLatitude,mEndLongitude),14,0,0)));
        // 添加一个终点标记
        aMap.addMarker(AMapUtil.addMarker(this,mEndLatitude,mEndLongitude,R.drawable.amap_end));
    }

    @Override
    protected void onResume() {
        super.onResume();
        mapView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mapView.onPause();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        mapView.onSaveInstanceState(outState);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(receiver);
        mapView.onDestroy();
    }

    private AMapLocationListener mapLocationListener = new AMapLocationListener() {
        //private Marker locationMarker = null;
        private LatLng lastLatLng = new LatLng(30.270044d,120.100018d);

        @Override
        public void onLocationChanged(AMapLocation aMapLocation) {
            LogUtil.d("收到定位回调——main，时间：" + new Date());
            if(aMapLocation.getErrorCode() == 0) {
                String text = String.format("定位成功\n省份：%s\n城市：%s\n区域：%s\n经纬度：%s,%s\n地址：%s\n速度：%f米/秒\n方向：%f\n定位来源：%s",
                        aMapLocation.getProvince(),
                        aMapLocation.getCity(),
                        aMapLocation.getDistrict(),
                        aMapLocation.getLatitude(),
                        aMapLocation.getLongitude(),
                        aMapLocation.getAddress(),
                        aMapLocation.getSpeed(),
                        aMapLocation.getBearing(),
                        FarmApplication.getInstance().getAmapLocationClient().getLocationTypeString(aMapLocation.getLocationType()));
                // 在界面上绘制Marker
                if(aMap == null) {
                    return;
                }
                if((aMapLocation.getLocationType() == 0 || aMapLocation.getLocationType() == 2)
                        || (moveMarker != null && aMapLocation.getLocationType() == 4)) {
                    // 定位失败的，前次定位的数据则不刷新图标，避免重复绘制
                    // 地图上已经绘制过，并且是缓存的定位数据，则不刷新,图标要停下来
                    if(moveMarker != null) {
                        moveMarker.stopMove();
                    }
                    return;
                }
                /* 若使用平滑移动图标，时段代码暂时不用// 此时说明已有图标
                if(locationMarker != null) {
                    // 定位失败的，前次定位的，缓存的数据则不刷新图标，避免重复绘制
                    if(aMapLocation.getLocationType() == 0 || aMapLocation.getLocationType() == 2 || aMapLocation.getLocationType() == 4) {
                        return;
                    }
                    locationMarker.remove();
                }*/
                // 绘制可平滑的特定图标
                if(moveMarker == null) {
                    moveMarker = new SmoothMoveMarker(aMap);
                    moveMarker.setDescriptor(BitmapDescriptorFactory.fromResource(R.mipmap.car));
                    LogUtil.d("绘制了新的定位图标");
                }

                double currentLat = Double.valueOf(aMapLocation.getLatitude());
                double currentLong = Double.valueOf(aMapLocation.getLongitude());
                moveSpeed = Float.valueOf(aMapLocation.getSpeed());
                moveDirection = Float.valueOf(aMapLocation.getBearing());
                LogUtil.d("moveSpeed:" + moveSpeed + ",moveDirection:" + moveDirection);
                /*locationMarker = aMap.addMarker(AMapUtil.addMarker(MainActivity.this,
                        currentLat,currentLong,R.mipmap.car));*/
                // 初始化路径规划
                initRouteSearch(currentLat,currentLong,mEndLatitude,mEndLongitude,mOnRouteSearchListener);
            } else {
                //定位失败时，可通过ErrCode（错误码）信息来确定失败的原因，errInfo是错误信息，详见错误码表。
                LogUtil.e("location Error, ErrCode:"
                        + aMapLocation.getErrorCode() + ", errInfo:"
                        + aMapLocation.getErrorInfo());
                //tvLocation.setText("定位失败，原因：" + aMapLocation.getErrorInfo());
            }
        }
    };

    private AMapLocationListener mapLocationListener2 = new AMapLocationListener() {
        private List<LatLng> allLatLngList = new ArrayList<LatLng>();
        private LatLng lastLatLng;      //上一次定位坐标
        /*private float lastSpeed;        // 上一次速度
        private float lastBearing;      // 上一次方向
        private long lastLocationTime;   // 上一次时间*/
        @Override
        public void onLocationChanged(AMapLocation aMapLocation) {
            LogUtil.d("收到定位回调2——main，时间：" + new Date());
            if(aMapLocation.getErrorCode() == 0) {
                //LogUtil.d("室内定位id信息：" + aMapLocation.getBuildingId() + ",楼层：" + aMapLocation.getFloor());
                // 在界面上绘制Marker
                if(aMap == null) {
                    return;
                }
                if((aMapLocation.getLocationType() == 0 || aMapLocation.getLocationType() == 2)
                        || (moveMarker != null && aMapLocation.getLocationType() == 4)) {
                    // 定位失败的，前次定位的数据则不刷新图标，避免重复绘制
                    // 地图上已经绘制过，并且是缓存的定位数据，则不刷新
                    return;
                }
                //记录当前经纬度
                moveLatlng = new LatLng(Double.valueOf(aMapLocation.getLatitude()),Double.valueOf(aMapLocation.getLongitude()));
                moveDirection = Float.valueOf(aMapLocation.getBearing());
                float currentSpeed = Float.valueOf(aMapLocation.getSpeed());
                if(moveMarker == null) {
                    moveMarker = new SmoothMoveMarker(aMap);
                    moveMarker.setDescriptor(BitmapDescriptorFactory.fromResource(R.mipmap.car));
                    LogUtil.d("绘制了新的定位图标2");
                }
                // 规划当前位置到终点的路线
                initRouteSearch(moveLatlng.latitude, moveLatlng.longitude, mEndLatitude, mEndLongitude, mOnRouteSearchListener);
                // 需要平滑移动的点列表
                List<LatLng> latLngList = new ArrayList<LatLng>();
                if(lastLatLng != null) {
                    LogUtil.d("开始平滑");
                    // 平滑上一点到当前点的轨迹
                    latLngList.add(lastLatLng);
                    latLngList.add(moveLatlng);
                    moveMarker.setPoints(latLngList);
                    moveMarker.setRotate(moveDirection);
                    moveMarker.setTotalDuration(4); // 定为周期慢一点
                    moveMarker.startSmoothMove();
                    /*// 先进行轨迹纠偏
                    myTraceClient.queryProcessedTrace(
                            new double[]{lastLatLng.latitude,currentLatLng.latitude},
                            new double[]{lastLatLng.longitude,currentLatLng.longitude},
                            new float[]{lastSpeed,Float.valueOf(aMapLocation.getSpeed())},
                            new float[]{lastBearing,moveDirection},
                            new long[]{lastLocationTime,aMapLocation.getTime()},mTraceListener);*/
                } else {
                    // 没有上一次定位说明刚进来的，显示图标
                    latLngList.add(moveLatlng);
                    moveMarker.setPoints(latLngList);
                    //moveMarker.setPosition(new LatLng(currentLat,currentLong));
                    moveMarker.setRotate(moveDirection);
                    moveMarker.setVisible(true);
                }
                // 添加到经纬度点列表
                allLatLngList.add(moveLatlng);
                // 把当前位置保留给上一次定位位置
                lastLatLng = moveLatlng;
            }
        }
    };

    /***** 地理围栏start *****/
    private void initGeoFence() {
        // 创建广播
        IntentFilter filter = new IntentFilter(ConnectivityManager.CONNECTIVITY_ACTION);
        filter.addAction(MyGeoFenceClient.ACTION_GEO_FENCE_EVENT);
        filter.addAction(MyGeoFenceClient.ACTION_GEO_FENCE_RESULT);
        registerReceiver(receiver, filter);
        DPoint geoFencePoint = new DPoint(mEndLatitude, mEndLongitude);
        myGeoFenceClient = FarmApplication.getInstance().getMyGeoFenceClient();
        myGeoFenceClient.addGeoFence(geoFencePoint, 1000f, "driver_travel");
    }

    private BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if(MyGeoFenceClient.ACTION_GEO_FENCE_RESULT.equals(intent.getAction())) {
                String customId = intent.getStringExtra("customId");
                int result = intent.getIntExtra("result",-1);
                if(result == 0) {
                    // 创建围栏成功
                    //tvGeoFence.append("创建围栏业务"+ customId + "成功\n");
                    if(aMap != null) {
                        myGeoFenceClient.drawFenceToMap(aMap);
                    }
                } else {
                    // 创建围栏失败
                    //tvGeoFence.append("创建围栏业务"+ customId + "失败\n");
                }
            } else if(MyGeoFenceClient.ACTION_GEO_FENCE_EVENT.equals(intent.getAction())) {
                //获取Bundle
                Bundle bundle = intent.getExtras();
                //获取围栏行为：
                int status = bundle.getInt(GeoFence.BUNDLE_KEY_FENCESTATUS);
                //获取自定义的围栏标识：
                String customId = bundle.getString(GeoFence.BUNDLE_KEY_CUSTOMID);
                //获取围栏ID:
                String fenceId = bundle.getString(GeoFence.BUNDLE_KEY_FENCEID);
                //获取当前有触发的围栏对象：
                GeoFence fence = bundle.getParcelable(GeoFence.BUNDLE_KEY_FENCE);
                switch (status) {
                    case MyGeoFenceClient.GEO_IN:
                        //tvGeoFence.append("业务id"+customId +"进入了围栏"+ fenceId +"\n");
                        Toast.makeText(MainActivity.this,"进入了围栏"+ fenceId,Toast.LENGTH_SHORT).show();
                        break;
                    case MyGeoFenceClient.GEO_OUT:
                        //tvGeoFence.append("业务id"+customId +"离开了围栏"+fenceId + "\n");
                        Toast.makeText(MainActivity.this,"离开了围栏"+ fenceId,Toast.LENGTH_SHORT).show();
                        break;
                    case MyGeoFenceClient.GEO_STAYED:
                        //tvGeoFence.append("业务id"+customId +"在围栏"+fenceId + "停留了10分钟\n");
                        Toast.makeText(MainActivity.this,"停留在围栏"+ fenceId,Toast.LENGTH_SHORT).show();
                        break;
                }
            }
        }
    };
    /***** 地理围栏end *****/

    /***** 路径规划start *****/
    private void initRouteSearch(double srcLat, double srcLong, double descLat, double descLong, RouteSearch.OnRouteSearchListener listener) {
        RouteSearch routeSearch = new RouteSearch(this);
        // 设置回调监听器
        routeSearch.setRouteSearchListener(listener);
        // fromAndTo包含路径规划的起点和终点，drivingMode表示驾车模式
        // 第三个参数表示途经点（最多支持16个），第四个参数表示避让区域（最多支持32个），第五个参数表示避让道路
        RouteSearch.FromAndTo fromAndTo = new RouteSearch.FromAndTo(new LatLonPoint(srcLat,srcLong),new LatLonPoint(descLat,descLong));
        RouteSearch.DriveRouteQuery driverQuery = new RouteSearch.DriveRouteQuery(fromAndTo, RouteSearch.DRIVING_SINGLE_DEFAULT, null, null, "");
        // 发送请求
        routeSearch.calculateDriveRouteAsyn(driverQuery);
    }

    private OnRouteSearchAdapter mOnRouteSearchListener = new OnRouteSearchAdapter() {
        private DrivingRouteOverlay drivingRouteOverlay;
        @Override
        public void onDriveRouteSearched(DriveRouteResult driveRouteResult, int i) {
            // 收到驾车导航路径规划
            if(i == 1000) {
                // 正确的
                if(driveRouteResult != null && driveRouteResult.getPaths() != null) {
                    if(driveRouteResult.getPaths().size() > 0) {
                        // 默认选择第一条
                        LogUtil.d("绘制了路径规划");
                        DrivePath drivePath = driveRouteResult.getPaths().get(0);
                        if(drivingRouteOverlay == null) {
                            drivingRouteOverlay = new DrivingRouteOverlay(
                                    MainActivity.this, aMap, drivePath,
                                    driveRouteResult.getStartPos(),
                                    driveRouteResult.getTargetPos(), null);
                        } else {
                            drivingRouteOverlay.refreshData(drivePath,driveRouteResult.getStartPos(),driveRouteResult.getTargetPos(),null);
                        }
                        drivingRouteOverlay.setNodeIconVisibility(false);//设置节点marker是否显示
                        drivingRouteOverlay.setIsColorfulline(true);//是否用颜色展示交通拥堵情况，默认true
                        drivingRouteOverlay.removeFromMap();
                        drivingRouteOverlay.addToMap();
                        //drivingRouteOverlay.zoomToSpan();
                        // 平移滑动
                        //initSmoothMove(drivingRouteOverlay.getAllPolyLines(),drivePath.getDistance());
                    } else {
                        // 没有找到数据

                    }
                } else {
                    // 没有找到数据
                }
            }
        }
    };

    /***** 路径规划end *****/

    /***** 点平滑移动start *****/
    private void initSmoothMove(List<Polyline> allPolyLine,double distance) {
        if(allPolyLine != null && allPolyLine.size() > 0) {
            // 将轨迹变成坐标点
            List<LatLng> allLatLng = new ArrayList<LatLng>();
            for(Polyline polyline : allPolyLine) {
                allLatLng.addAll(polyline.getPoints());
            }
            moveMarker.setPoints(allLatLng);
            // 计算当前点到目的地的时间
            if(moveSpeed > 0) {
                // 计算时间
                int totalDuration = (int) (distance/moveSpeed)+1;
                moveMarker.setTotalDuration(totalDuration);
                moveMarker.startSmoothMove();
            } else {
                // 速度等于0 说明处于停止状态
                // 停止
                moveMarker.stopMove();
                moveMarker.setRotate(moveDirection);
                moveMarker.setVisible(true);
            }
            /*if(moveMarker != null) {
                moveMarker.setPoints(allLatLng);//设置平滑移动的轨迹list
                moveMarker.setTotalDuration(60);//设置平滑移动的总时间
                moveMarker.startSmoothMove();
            }*/
        }
    }

    private void initSmoothMove2(final List<Polyline> allPolyLine){
        if(allPolyLine != null && allPolyLine.size() > 0) {
            // 将轨迹变成坐标点
            List<LatLng> allLatLng = new ArrayList<LatLng>();
            for (Polyline polyline : allPolyLine) {
                allLatLng.addAll(polyline.getPoints());
            }
            if(moveMarker != null) {
                moveMarker.setMoveListener(new SmoothMoveMarker.MoveListener() {
                    @Override
                    public void move(double v) {
                        if(v == 0) {
                            // 走完了，把该段路径消掉
                            for(Polyline polyline : allPolyLine) {
                                polyline.remove();
                            }
                        }
                    }
                });
                moveMarker.setPoints(allLatLng);
                moveMarker.setTotalDuration(3); // 4秒走完
                moveMarker.setRotate(moveDirection);// 设置方向
                moveMarker.startSmoothMove();
            }
        }

    }
    /***** 点平滑移动end *****/

    /***** 轨迹纠偏start *****/
    private TraceListener mTraceListener = new TraceListener() {

        @Override
        public void onRequestFailed(int i, String s) {
            LogUtil.e("轨迹纠偏失败:" + s);
            //Toast.makeText(MainActivity.this,"轨迹纠偏失败:" + s,Toast.LENGTH_SHORT).show();
        }

        @Override
        public void onTraceProcessing(int i, int i1, List<LatLng> list) {

        }

        @Override
        public void onFinished(int i, List<LatLng> list, int i1, int i2) {
            // 轨迹纠偏完成
            LogUtil.d("轨迹纠偏完成");
            //Toast.makeText(MainActivity.this,"轨迹纠偏完成:",Toast.LENGTH_SHORT).show();
            moveMarker.setPoints(list);
            moveMarker.setRotate(moveDirection);
            moveMarker.setTotalDuration(4); // 必定为周期慢一点
            moveMarker.startSmoothMove();
            // initRouteSearch(lastLatLng.latitude,lastLatLng.longitude,currentLat,currentLong,mOnRouteSearchListener2);
        }
    };
    /***** 轨迹纠偏end *****/

    /****** 导航相关start ******/
    public void startNavi(View view) {
        if(moveLatlng == null) {
            return;
        }
        Poi start = new Poi("",moveLatlng,"");
        Poi end = new Poi("", new LatLng(mEndLatitude, mEndLongitude), "");
        AmapNaviPage.getInstance().showRouteActivity(this, new AmapNaviParams(start, null, end, AmapNaviType.DRIVER), new AMapNaviInfoCallbackAdapter() {

        });
    }
    /****** 导航相关end ******/

}

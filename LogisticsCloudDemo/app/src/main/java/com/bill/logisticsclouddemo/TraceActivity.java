package com.bill.logisticsclouddemo;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.view.View;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.maps.AMap;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.MapView;
import com.amap.api.maps.UiSettings;
import com.amap.api.maps.model.BitmapDescriptorFactory;
import com.amap.api.maps.model.CameraPosition;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.Polyline;
import com.amap.api.maps.utils.overlay.SmoothMoveMarker;
import com.amap.api.trace.TraceListener;
import com.bill.logisticsclouddemo.amap.AMapUtil;
import com.bill.logisticsclouddemo.amap.MyLocationClient;
import com.bill.logisticsclouddemo.amap.model.DBLatLng;
import com.bill.logisticsclouddemo.amap.model.DBTraceLocation;

import java.util.ArrayList;
import java.util.List;

/**
 * 用于测试历史轨迹纠偏测试用的活动
 * Created by Bill56 on 2018-3-13.
 */

public class TraceActivity extends AppCompatActivity {

    private MapView mapView;
    private AMap aMap;

    // 数据
    private double mEndLatitude = 30.267384d,mEndLongitude = 120.092691d;
    private double mDriverLatitude,mDriverLongitude;
    private SmoothMoveMarker moveMarker;    // 当前定位点图标
    private LatLng mLastTraceLatLng; // 上一已纠偏段路的坐标点

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_trace);
        mapView = (MapView) findViewById(R.id.map);
        mapView.onCreate(savedInstanceState);
        // 初始化地图
        initAMap();
        // 初始化已纠偏的数据
        initHistoryRectifyTrace();
        // 开启定位操作
        FarmApplication.getInstance().getAmapLocationClient().start(mAMapLocationListener);
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

    /******     定位相关start    ******/
    private AMapLocationListener mAMapLocationListener = new AMapLocationListener() {

        private long count = 0;
        // 轨迹查询周期
        private int traceCycle = 30 / MyLocationClient.cycle;   // 30秒内定位多少次，如5秒定位一次，那么该值为6

        @Override
        public void onLocationChanged(AMapLocation aMapLocation) {
            LogUtil.d("收到定位回调");
            count ++;
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
                LogUtil.d("定位信息：" + text);
                // 定位成功
                DBTraceLocation dbTraceLocation = new DBTraceLocation(aMapLocation.getLatitude(),
                        aMapLocation.getLongitude(), aMapLocation.getSpeed(),
                        aMapLocation.getBearing(),aMapLocation.getTime());
                // 保存到本地数据库
                dbTraceLocation.save();
                if(moveMarker == null) {
                    moveMarker = new SmoothMoveMarker(aMap);
                    moveMarker.setDescriptor(BitmapDescriptorFactory.fromResource(R.mipmap.car));
                    List<LatLng> latLngList = new ArrayList<LatLng>();
                    latLngList.add(new LatLng(aMapLocation.getLatitude(),aMapLocation.getLongitude()));
                    moveMarker.setPoints(latLngList);
                    moveMarker.setRotate(aMapLocation.getBearing());
                    moveMarker.setVisible(true);
                    ToastUtil.show(TraceActivity.this,"绘制了定位点的车标");
                }
            }
            if(count % traceCycle == 0) {
                // 去纠偏
                getHistoryTrace();
            }
        }
    };
    /******     定位相关end    ******/

    /******     轨迹相关start     ******/
    // 初始化已纠偏的历史轨迹
    private void initHistoryRectifyTrace() {
        // 查询已纠偏的数据
        LogUtil.d("已纠偏数据查询绘制");
        List<DBLatLng> dbLatLngs = DBLatLng.listAll(DBLatLng.class);
        List<LatLng> latLngList = AMapUtil.convertToAMapLatLng(dbLatLngs);
        if(latLngList != null && latLngList.size() > 0) {
            // 有纠偏成功数据，在最后一个点绘制车标数据
            LogUtil.d("纠偏成功点数量：" + latLngList.size());
            mLastTraceLatLng = latLngList.get(latLngList.size()-1);
            aMap.addPolyline(AMapUtil.addPolylineCustomTexturePoints(latLngList,R.drawable.custtexture));
            // 绘制最后一个点的位置的车标
            if(moveMarker == null) {
                moveMarker = new SmoothMoveMarker(aMap);
                moveMarker.setDescriptor(BitmapDescriptorFactory.fromResource(R.mipmap.car));
                List<LatLng> latLngList2 = new ArrayList<LatLng>();
                latLngList2.add(mLastTraceLatLng);
                moveMarker.setPoints(latLngList2);
                moveMarker.setVisible(true);
                ToastUtil.show(this,"绘制了历史点最后一个位置的车标");
            }
        }
    }

    // 初始化未纠偏的历史轨迹
    private void getHistoryTrace() {
        LogUtil.d("开始轨迹纠偏");
        // 从本地拿未纠偏的数据
        final List<DBTraceLocation> dbTraceLocationList = DBTraceLocation.listAll(DBTraceLocation.class);
        LogUtil.d("纠偏点数量：" + dbTraceLocationList.size());
        // 如果历史点轨迹大于1才进行纠偏，高德地图纠偏要求纠偏轨迹不少于2个
        if(dbTraceLocationList != null && dbTraceLocationList.size() > 1) {
            FarmApplication.getInstance().getMyTraceClient().queryProcessedTrace(AMapUtil.convertToAMapTraceLocationList(dbTraceLocationList),
                    new TraceListener() {

                        @Override
                        public void onRequestFailed(int lineID, String errorInfo) {
                            // 纠偏失败不操作，保留到下一次继续纠偏
                            LogUtil.d("纠偏失败");
                        }

                        @Override
                        public void onTraceProcessing(int lineID, int index, List<LatLng> segments) {
                            // 分段绘制路段
                            if(index == 0 && mLastTraceLatLng != null) {
                                // 如果是第一段路，需要加入前一段路的最后一个纠偏后的坐标
                                segments.add(0,mLastTraceLatLng);
                            }
                            aMap.addPolyline(AMapUtil.addPolylineCustomTexturePoints(segments,R.drawable.custtexture));
                            // 保存已纠偏点数据
                            DBLatLng.saveInTx(AMapUtil.convertToDBLatLng(segments));
                        }

                        @Override
                        public void onFinished(int lineID, List<LatLng> linePoints, int distance, int waitingTime) {
                            LogUtil.d("纠偏成功");
                            // 开始平滑
                            if(linePoints != null && linePoints.size() > 0) {
                                if(mLastTraceLatLng != null) {
                                    linePoints.add(0,mLastTraceLatLng);
                                }
                                initSmoothMove(linePoints);
                                mLastTraceLatLng = linePoints.get(linePoints.size() - 1);
                                // 删除已纠偏点数据
                                DBTraceLocation.deleteInTx(dbTraceLocationList);
                            }
                        }
                    });
        }
    }
    /******     轨迹相关end     ******/

    /******     平滑相关start     ******/
    private void initSmoothMove(List<LatLng> allLatLng) {
        if(allLatLng != null && allLatLng.size() > 0) {
            if(moveMarker == null) {
                moveMarker = new SmoothMoveMarker(aMap);
                moveMarker.setDescriptor(BitmapDescriptorFactory.fromResource(R.mipmap.car));
                LogUtil.d("绘制了车标图标");
            }
            moveMarker.setPoints(allLatLng);
            moveMarker.setTotalDuration(25);
            moveMarker.startSmoothMove();
        }
    }

    /******     平滑相关end     ******/

    /******      点击事件start      ******/
    public void clearDBLatLng(View v) {
        DBLatLng.deleteAll(DBLatLng.class);
    }

    public void clearDBTrace(View v) {
        DBTraceLocation.deleteAll(DBTraceLocation.class);
    }

    public void clearDBAll(View v) {
        clearDBLatLng(v);
        clearDBTrace(v);
    }
    /******      点击事件end      ******/

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
        mapView.onDestroy();
    }

}

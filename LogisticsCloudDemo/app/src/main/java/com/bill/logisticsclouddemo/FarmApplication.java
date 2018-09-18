package com.bill.logisticsclouddemo;

import android.app.Application;

import com.bill.logisticsclouddemo.amap.MyGeoFenceClient;
import com.bill.logisticsclouddemo.amap.MyLocationClient;
import com.bill.logisticsclouddemo.amap.MyTraceClient;
import com.orm.SugarContext;

/**
 * Created by Bill56 on 2018-3-7.
 */

public class FarmApplication extends Application {

    // 高德地图对象
    private MyLocationClient myLocationClient;  // 定位客户端对象
    private MyGeoFenceClient myGeoFenceClient;  // 地理围栏客户端对象
    private MyTraceClient myTraceClient;        // 轨迹纠偏客户端对象

    private static FarmApplication mInstance;

    public static FarmApplication getInstance() {
        return mInstance;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        mInstance = this;
        initAMap();
        // 初始化sugar数据库
        SugarContext.init(this);
    }

    // 初始化高德地图
    private void initAMap() {
        myLocationClient = new MyLocationClient(this);
        myGeoFenceClient = new MyGeoFenceClient(this);
        myTraceClient = new MyTraceClient(this);
    }

    public MyLocationClient getAmapLocationClient() {
        return myLocationClient;
    }

    public MyGeoFenceClient getMyGeoFenceClient() {return myGeoFenceClient;}

    public MyTraceClient getMyTraceClient() {
        return myTraceClient;
    }
}

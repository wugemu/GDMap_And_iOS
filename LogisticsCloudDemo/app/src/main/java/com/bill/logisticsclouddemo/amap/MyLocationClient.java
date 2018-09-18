package com.bill.logisticsclouddemo.amap;

import android.content.Context;
import android.support.annotation.NonNull;

import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;

/**
 * 自定义的高德定位SDK相关封装——出行类
 * Created by Bill56 on 2018-3-7.
 */

public class MyLocationClient {

    public static int cycle = 5;
    //声明AMapLocationClient类对象
    private AMapLocationClient mLocationClient = null;
    //声明AMapLocationClientOption对象
    private AMapLocationClientOption mLocationOption = null;
    private AMapLocationListener mAMapLocationListener = null;
    // 定位来源数组，坐标为3和7没有数据
    private String[] locationTypeArr = {"定位失败","GPS定位结果","前次定位结果","","缓存定位结果","Wifi定位结果","基站定位结果","","离线定位结果"};

    // private static MyLocationClient mInstance;

    // 私有构造方法
    public MyLocationClient(Context context) {
        //初始化定位
        mLocationClient = new AMapLocationClient(context.getApplicationContext());
        //设置默认定位回调监听，将该设置放到start方法中
        // mLocationClient.setLocationListener(mLocationListener);
        //初始化AMapLocationClientOption对象
        mLocationOption = new AMapLocationClientOption();
        /**
         * 设置定位场景，目前支持三种场景（签到、出行、运动，默认无场景）
         * 这里使用出行场景，高精度连续定位，适用于有户内外切换的场景，
         * GPS和网络定位相互切换，GPS定位成功之后网络定位不再返回，GPS断开之后一段时间才会返回网络结果，
         * 使用连续定位
         */
        mLocationOption.setLocationPurpose(AMapLocationClientOption.AMapLocationPurpose.Transport);
        mLocationOption.setSensorEnable(true);
        mLocationOption.setInterval(cycle * 1000);  // 定位周期改成5秒
        //mLocationOption.setOnceLocation(true);  // 设置只定位一次
        // 把定位参数传给定位对象
        mLocationClient.setLocationOption(mLocationOption);
    }

    /*public static MyLocationClient getInstance(Context context) {
        if(mInstance == null){
            synchronized (MyLocationClient.class){
                if(mInstance == null){
                    mInstance = new MyLocationClient(context);
                }
            }
        }
        return mInstance;
    }*/


    public void start(@NonNull AMapLocationListener aMapLocationListener) {
        if(null != mLocationClient){
            // 先调用停止定位方法
            stop();
            if(aMapLocationListener != null) {
                mLocationClient.setLocationListener(aMapLocationListener);
                this.mAMapLocationListener = aMapLocationListener;
            }
            mLocationClient.startLocation();
        }
    }

    public void stop() {
        if(null != mLocationClient && mLocationClient.isStarted()) {
            mLocationClient.stopLocation();
            if(mAMapLocationListener != null) {
                mLocationClient.unRegisterLocationListener(mAMapLocationListener);
            }
        }
    }

    public void onDestroy() {
        if(null != mLocationClient) {
            mLocationClient.onDestroy();
        }
    }

    public String getLocationTypeString(int locationType) {
        if(locationType >= 0 && locationType<locationTypeArr.length) {
            return locationTypeArr[locationType];
        }
        return null;
    }

}

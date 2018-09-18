package com.bill.logisticsclouddemo.amap;

import android.content.Context;

import com.amap.api.trace.LBSTraceClient;
import com.amap.api.trace.TraceListener;
import com.amap.api.trace.TraceLocation;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * 自定义高德轨迹纠偏SDK相关封装
 * Created by Bill56 on 2018-3-9.
 */

public class MyTraceClient {

    private LBSTraceClient mTraceClient;

    public MyTraceClient(Context context) {
        // 初始化轨迹纠偏客户端对象
        mTraceClient = LBSTraceClient.getInstance(context);
    }

    @Deprecated
    public void queryProcessedTrace(double[] latitudes, double[] longitudes, float[] speeds,
                                    float[] bearings, long[] times, TraceListener listener) {
        if(latitudes == null || latitudes.length < 2
                || longitudes == null || longitudes.length < 2
                || speeds == null || speeds.length < 2
                || bearings == null || bearings.length < 2
                || times == null || times.length < 2) {
            // 要传入的坐标点数据至少要2个
            return;
        }
        List<TraceLocation> traceLocationList = new ArrayList<TraceLocation>();
        for(int i = 0;i<latitudes.length;i++) {
            traceLocationList.add(new TraceLocation(latitudes[i],longitudes[i],speeds[i],bearings[i],times[i]));
        }
        mTraceClient.queryProcessedTrace((int) System.currentTimeMillis(),traceLocationList,LBSTraceClient.TYPE_AMAP,listener);
    }

    public void queryProcessedTrace(List<TraceLocation> traceLocationList,TraceListener listener) {
        if(traceLocationList == null || traceLocationList.size() < 2) {
            // 纠偏轨迹不能少于2个
            return;
        }
        mTraceClient.queryProcessedTrace((int) System.currentTimeMillis(),traceLocationList,LBSTraceClient.TYPE_AMAP,listener);
    }

}

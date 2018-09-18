package com.bill.logisticsclouddemo.amap;

import android.content.Context;
import android.content.Intent;

import com.amap.api.fence.GeoFence;
import com.amap.api.fence.GeoFenceClient;
import com.amap.api.fence.GeoFenceListener;
import com.amap.api.location.DPoint;
import com.amap.api.maps.AMap;
import com.amap.api.maps.model.Circle;
import com.amap.api.maps.model.CircleOptions;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.Polygon;
import com.amap.api.maps.model.PolygonOptions;
import com.bill.logisticsclouddemo.LogUtil;
import com.bill.logisticsclouddemo.R;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;


/**
 * 自定义高德地理围栏SDK相关封装
 * Created by Bill56 on 2018-3-7.
 */

public class MyGeoFenceClient {

    // 定义接收围栏广播的action字符串
    public static final String ACTION_GEO_FENCE_EVENT = ".GEO_FENCE_EVENT";
    public static final String ACTION_GEO_FENCE_RESULT = ".GEO_FENCE_RESULT";
    // 围栏行为
    public static final int GEO_IN = GeoFenceClient.GEOFENCE_IN;
    public static final int GEO_OUT = GeoFenceClient.GEOFENCE_OUT;
    public static final int GEO_STAYED = GeoFenceClient.GEOFENCE_STAYED;

    // 上下文环境
    private Context mContext;
    // 地理围栏客户端对象
    private GeoFenceClient mGeoFenceClient = null;
    // 记录已经添加成功的围栏
    private volatile ConcurrentMap<String, GeoFence> fenceMap = new ConcurrentHashMap<String, GeoFence>();
    private ConcurrentMap mCustomEntitys = new ConcurrentHashMap<String, Object>();

    public MyGeoFenceClient(Context context) {
        mContext = context.getApplicationContext();
        // 实例化地理围栏客户端
        mGeoFenceClient = new GeoFenceClient(mContext);
        // 设置希望侦测的围栏触发行为，默认只侦测用户进入围栏的行为，这里设置进入，离开，停留10分钟
        mGeoFenceClient.setActivateAction(GEO_IN|GEO_OUT|GEO_STAYED);
        // 创建围栏结果的回调
        mGeoFenceClient.setGeoFenceListener(new GeoFenceListener() {
            @Override
            public void onGeoFenceCreateFinished(List<GeoFence> list, int i, String s) {
                // 发送广播
                if(i == GeoFence.ADDGEOFENCE_SUCCESS) {
                    // 创建成功
                    for(GeoFence fence : list) {
                        fenceMap.putIfAbsent(fence.getFenceId(), fence);
                    }
                }
                LogUtil.d( "回调添加成功个数:" + list.size());
                LogUtil.d("回调添加围栏个数:" + fenceMap.size());
                Intent intent = new Intent(ACTION_GEO_FENCE_RESULT);
                intent.putExtra("result",i);
                intent.putExtra("customId",s);
                mContext.sendBroadcast(intent);
            }
        });
        // 创建并设置PendingIntent
        mGeoFenceClient.createPendingIntent(ACTION_GEO_FENCE_EVENT);
    }

    // 添加一个地理围栏，并且清除之前的围栏
    public void addGeoFence(DPoint point, float radius, String customId) {
        addGeoFence(point, radius, customId, true);
    }

    /**
     * 添加一个地理围栏
     *
     * @param point    中心点
     * @param radius   半径，单位：米
     * @param customId 与围栏关联的自有业务id
     * @param isClear  是否清除之前的围栏
     */
    public void addGeoFence(DPoint point, float radius, String customId, boolean isClear) {
        if (mGeoFenceClient != null) {
            if (isClear) {
                clearAll();
            }
            mGeoFenceClient.addGeoFence(point, radius, customId);
        }
    }

    public void clearAll() {
        if (mGeoFenceClient != null) {
            mGeoFenceClient.removeGeoFence();
            fenceMap.clear();
        }
    }

    /**
     * 以下是绘制地图用的方法
     */
    //绘制多边形
    private void drawPolygon(AMap aMap, GeoFence fence) {
        final List<List<DPoint>> pointList = fence.getPointList();
        if (null == pointList || pointList.isEmpty()) {
            return;
        }
        List<Polygon> polygonList = new ArrayList<Polygon>();
        for (List<DPoint> subList : pointList) {
            if (subList == null) {
                continue;
            }
            List<LatLng> lst = new ArrayList<LatLng>();

            PolygonOptions polygonOption = new PolygonOptions();
            for (DPoint point : subList) {
                lst.add(new LatLng(point.getLatitude(), point.getLongitude()));
//                boundsBuilder.include(
//                        new LatLng(point.getLatitude(), point.getLongitude()));
            }
            polygonOption.addAll(lst);

            polygonOption.fillColor(mContext.getResources().getColor(R.color.fill));
            polygonOption.strokeColor(mContext.getResources().getColor(R.color.stroke));
            polygonOption.strokeWidth(4);
            Polygon polygon = aMap.addPolygon(polygonOption);
            polygonList.add(polygon);
            mCustomEntitys.put(fence.getFenceId(),polygonList);
        }
    }

    // 绘制原型
    private void drawCircle(AMap aMap,GeoFence fence) {
        CircleOptions option = new CircleOptions();
        option.fillColor(mContext.getResources().getColor(R.color.fill));
        option.strokeColor(mContext.getResources().getColor(R.color.stroke));
        option.strokeWidth(4);
        option.radius(fence.getRadius());
        DPoint dPoint = fence.getCenter();
        option.center(new LatLng(dPoint.getLatitude(), dPoint.getLongitude()));
        Circle circle = aMap.addCircle(option);
        mCustomEntitys.put(fence.getFenceId(), circle);
    }

    public void drawFenceToMap(AMap aMap) {
        Iterator iter = fenceMap.entrySet().iterator();
        while (iter.hasNext()) {
            Map.Entry entry = (Map.Entry) iter.next();
            String key = (String) entry.getKey();
            GeoFence val = (GeoFence) entry.getValue();
            if (!mCustomEntitys.containsKey(key)) {
                LogUtil.d("添加围栏:" + key);
                drawFence(aMap,val);
            }
        }
    }

    private void drawFence(AMap aMap,GeoFence fence) {
        switch (fence.getType()) {
            case GeoFence.TYPE_ROUND:
            case GeoFence.TYPE_AMAPPOI:
                drawCircle(aMap,fence);
                break;
            case GeoFence.TYPE_POLYGON:
            case GeoFence.TYPE_DISTRICT:
                drawPolygon(aMap,fence);
                break;
            default:
                break;
        }

        // 设置所有maker显示在当前可视区域地图中
//        LatLngBounds bounds = boundsBuilder.build();
//        mAMap.moveCamera(CameraUpdateFactory.newLatLngBounds(bounds, 150));
//        polygonPoints.clear();
//        removeMarkers();
    }

}

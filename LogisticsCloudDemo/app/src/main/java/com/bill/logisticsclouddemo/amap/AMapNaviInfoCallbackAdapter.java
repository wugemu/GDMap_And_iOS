package com.bill.logisticsclouddemo.amap;

import com.amap.api.navi.INaviInfoCallback;
import com.amap.api.navi.model.AMapNaviLocation;
import com.bill.logisticsclouddemo.LogUtil;

/**
 * Created by Bill56 on 2018-3-9.
 */

public class AMapNaviInfoCallbackAdapter implements INaviInfoCallback {
    @Override
    public void onInitNaviFailure() {
        LogUtil.e("导航初始化失败");
    }

    @Override
    public void onGetNavigationText(String s) {
        LogUtil.d("播报的语音文字为：" + s);
    }

    @Override
    public void onLocationChange(AMapNaviLocation aMapNaviLocation) {

    }

    @Override
    public void onArriveDestination(boolean b) {

    }

    @Override
    public void onStartNavi(int i) {
        LogUtil.d("导航启动成功");
    }

    @Override
    public void onCalculateRouteSuccess(int[] ints) {

    }

    @Override
    public void onCalculateRouteFailure(int i) {

    }

    @Override
    public void onStopSpeaking() {
        LogUtil.e("语音播报停止");
    }

    @Override
    public void onReCalculateRoute(int i) {

    }

    @Override
    public void onExitPage(int i) {

    }
}

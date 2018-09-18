package com.bill.logisticsclouddemo.amap.model;

import com.orm.SugarRecord;

/**
 * 勇于保存到sqlite的实体类
 * Created by Bill56 on 2018-3-14.
 */

public class DBTraceLocation extends SugarRecord {

    /*@Unique
    long identity;*/
    double latitude;
    double longitude;
    float speed;
    float bearing;
    long time;

    // 默认构造方法
    public DBTraceLocation() {

    }

    public DBTraceLocation(double latitude, double longitude, float speed, float bearing, long time) {
        //this.identity = identity;
        this.latitude = latitude;
        this.longitude = longitude;
        this.speed = speed;
        this.bearing = bearing;
        this.time = time;
    }

    /*public long getIdentity() {
        return identity;
    }

    public void setIdentity(long identity) {
        this.identity = identity;
    }*/

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public float getSpeed() {
        return speed;
    }

    public void setSpeed(float speed) {
        this.speed = speed;
    }

    public float getBearing() {
        return bearing;
    }

    public void setBearing(float bearing) {
        this.bearing = bearing;
    }

    public long getTime() {
        return time;
    }

    public void setTime(long time) {
        this.time = time;
    }

}


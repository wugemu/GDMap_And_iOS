package com.bill.logisticsclouddemo.amap.model;

import com.orm.SugarRecord;

/**
 * Created by Bill56 on 2018-3-16.
 */

public class DBLatLng extends SugarRecord {

    double latitude;
    double longitude;

    public DBLatLng() {
    }

    public DBLatLng(double latitude, double longitude) {
        this.latitude = latitude;
        this.longitude = longitude;
    }

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
}

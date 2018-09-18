/**
 * 
 */
package com.bill.logisticsclouddemo.amap;

import android.content.Context;

import com.amap.api.maps.model.BitmapDescriptorFactory;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.MarkerOptions;
import com.amap.api.maps.model.PolylineOptions;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.trace.TraceLocation;
import com.bill.logisticsclouddemo.amap.model.DBLatLng;
import com.bill.logisticsclouddemo.amap.model.DBTraceLocation;

import java.util.ArrayList;
import java.util.List;

public class AMapUtil {




	/**
	 * 把LatLng对象转化为LatLonPoint对象
	 */
	public static LatLonPoint convertToLatLonPoint(LatLng latlon) {
		return new LatLonPoint(latlon.latitude, latlon.longitude);
	}

	/**
	 * 把LatLonPoint对象转化为LatLon对象
	 */
	public static LatLng convertToLatLng(LatLonPoint latLonPoint) {
		return new LatLng(latLonPoint.getLatitude(), latLonPoint.getLongitude());
	}

	/**
	 * 把集合体的LatLonPoint转化为集合体的LatLng
	 */
	public static ArrayList<LatLng> convertArrList(List<LatLonPoint> shapes) {
		ArrayList<LatLng> lineShapes = new ArrayList<LatLng>();
		for (LatLonPoint point : shapes) {
			LatLng latLngTemp = AMapUtil.convertToLatLng(point);
			lineShapes.add(latLngTemp);
		}
		return lineShapes;
	}

	public static TraceLocation convertToAMapTraceLocation(DBTraceLocation dbTraceLocation) {
		if(dbTraceLocation == null) {
			return null;
		}
		return new TraceLocation(dbTraceLocation.getLatitude(),dbTraceLocation.getLongitude(),
				dbTraceLocation.getSpeed(),dbTraceLocation.getBearing(),dbTraceLocation.getTime());
	}

	public static List<TraceLocation> convertToAMapTraceLocationList(List<DBTraceLocation> dbTraceLocations) {
		if(dbTraceLocations == null || dbTraceLocations.size() <= 0) {
			return null;
		}
		List<TraceLocation> traceLocationList = new ArrayList<TraceLocation>();
		for (DBTraceLocation dbTraceLocation : dbTraceLocations) {
			traceLocationList.add(convertToAMapTraceLocation(dbTraceLocation));
		}
		return traceLocationList;
	}

	public static List<LatLng> convertToAMapLatLng(List<DBLatLng> dbLatLngList) {
		if(dbLatLngList == null || dbLatLngList.size() <= 0) {
			return null;
		}
		List<LatLng> latLngs = new ArrayList<LatLng>();
		for(DBLatLng dbLatLng : dbLatLngList) {
			latLngs.add(new LatLng(dbLatLng.getLatitude(),dbLatLng.getLongitude()));
		}
		return latLngs;
	}

	public static List<DBLatLng> convertToDBLatLng(List<LatLng> latLngList) {
		if(latLngList == null || latLngList.size() <= 0) {
			return null;
		}
		List<DBLatLng> dbLatLngList = new ArrayList<DBLatLng>();
		for(LatLng latLng : latLngList) {
			dbLatLngList.add(new DBLatLng(latLng.latitude,latLng.longitude));
		}
		return dbLatLngList;
	}

	public static MarkerOptions addMarker(Context context, double latitude, double longitude, int resourceId) {
		return addMarker(context,latitude,longitude,resourceId,false);
	}

	public static MarkerOptions addMarker(Context context,double latitude, double longitude, int resourceId, boolean draggable) {
		MarkerOptions markerOption = new MarkerOptions();
		markerOption.position(new LatLng(latitude,longitude));
		markerOption.draggable(draggable);//设置Marker是否可拖动
		markerOption.icon(BitmapDescriptorFactory.fromResource(resourceId));
		return markerOption;
	}

	/**
	 * 根据轨迹点生成线
	 * @param latLngList 轨迹点
	 * @param color 轨迹颜色
	 * @return
	 */
	public static PolylineOptions addPolylinePoints(List<LatLng> latLngList,int color) {
		if(latLngList == null || latLngList.size() <= 0) {
			return null;
		}
		PolylineOptions polylineOptions = new PolylineOptions();
		polylineOptions.color(color).addAll(latLngList).width(25);
		return polylineOptions;
	}

	public static PolylineOptions addPolylineCustomTexturePoints(List<LatLng> latLngList,int resourceId) {
		if(latLngList == null || latLngList.size() <= 0) {
			return null;
		}
		PolylineOptions polylineOptions = new PolylineOptions();
		polylineOptions.setCustomTexture(BitmapDescriptorFactory.fromResource(resourceId))
				.addAll(latLngList)
				.useGradient(true)
				.width(18);
		return polylineOptions;
	}

}

/**
 *
 */
package de.museum4punkt0.ingelheim.panorama.panorama;

import android.hardware.Sensor;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;

import java.util.ArrayList;
import java.util.List;

import de.museum4punkt0.ingelheim.panorama.panorama.representation.EulerAngles;
import de.museum4punkt0.ingelheim.panorama.panorama.representation.Matrixf4x4;
import de.museum4punkt0.ingelheim.panorama.panorama.representation.Quaternion;

/**
 * Classes implementing this interface provide an orientation of the device
 * either by directly accessing hardware, using Android sensor fusion or fusing
 * sensors itself.
 *
 * The orientation can be provided as rotation matrix or quaternion.
 *
 * @author Alexander Pacha (https://github.com/apacha/sensor-fusion-demo/tree/main)
 *
 * License:
 * Copyright, 2023, by Alexander Pacha and the Human Technology Laboratory New Zealand.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 */
public abstract class OrientationProvider implements SensorEventListener {

    protected ICallback mCallback;

    /**
     * Sync-token for syncing read/write to sensor-data from sensor manager and
     * fusion algorithm
     */
    protected final Object syncToken = new Object();

    /**
     * The list of sensors used by this provider
     */
    protected List<Sensor> sensorList = new ArrayList<Sensor>();

    /**
     * The matrix that holds the current rotation
     */
    protected final Matrixf4x4 currentOrientationRotationMatrix;

    /**
     * The quaternion that holds the current rotation
     */
    protected final Quaternion currentOrientationQuaternion;

    /**
     * The sensor manager for accessing android sensors
     */
    protected SensorManager sensorManager;
    protected MODE mMode;
    protected int accuracy;

    /**
     * Initialises a new OrientationProvider
     *
     * @param sensorManager The android sensor manager
     */
    public OrientationProvider(SensorManager sensorManager, MODE mode) {
        this.sensorManager = sensorManager;
        mMode = mode;

        // Initialise with identity
        currentOrientationRotationMatrix = new Matrixf4x4();

        // Initialise with identity
        currentOrientationQuaternion = new Quaternion();
    }

    /**
     * LOOK_THROUGH MODE returns best values when looking through the device, for example using the
     * camera with AR FLAT MODE returns best values when holding device flat, for example as a
     * compass or with a map
     */
    public enum MODE {
        LOOK_THROUGH, FLAT
    }

    ;

    /**
     * Starts the sensor fusion (e.g. when resuming the activity)
     */
    public void start() {
        // enable our sensor when the activity is resumed, ask for
        // 10 ms updates.
        for (Sensor sensor : sensorList) {
            // enable our sensors when the activity is resumed, ask for
            // 20 ms updates (Sensor_delay_game)
            sensorManager.registerListener(this, sensor,
                    SensorManager.SENSOR_DELAY_GAME);
        }
    }

    /**
     * Stops the sensor fusion (e.g. when pausing/suspending the activity)
     */
    public void stop() {
        // make sure to turn our sensors off when the activity is paused
        for (Sensor sensor : sensorList) {
            sensorManager.unregisterListener(this, sensor);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        this.accuracy = accuracy;
        if (mCallback != null) {
            mCallback.onAccuracyChanged(accuracy);
        }
    }

    /**
     * @return Returns the current rotation of the device in the rotation matrix format (4x4 matrix)
     */
    public Matrixf4x4 getRotationMatrix() {
        synchronized (syncToken) {
            return currentOrientationRotationMatrix;
        }
    }

    /**
     * @return Returns the current rotation of the device in the quaternion format (vector4f)
     */
    public Quaternion getQuaternion() {
        synchronized (syncToken) {
            return currentOrientationQuaternion.clone();
        }
    }

    /**
     * @return Returns the current rotation of the device in the Euler-Angles
     */
    public EulerAngles getEulerAngles() {
        synchronized (syncToken) {

            float[] angles = new float[3];
            SensorManager.getOrientation(currentOrientationRotationMatrix.matrix, angles);
            return new EulerAngles(angles[0], angles[1], angles[2]);
        }
    }

    public interface ICallback {

        void onOrientationChanged(float[] orientationDegrees);

        void onNoSensorFound();

        void onAccuracyChanged(int accuracy);
    }

    protected float[] mOrientationDegrees = new float[3];

    public float getAzimuth() {
        return mOrientationDegrees[0];
    }

    public float getPitch() {
        return mOrientationDegrees[1];
    }

    public float getRoll() {
        return mOrientationDegrees[2];
    }
}

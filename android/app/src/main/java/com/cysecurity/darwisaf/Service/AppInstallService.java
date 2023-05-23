package com.cysecurity.darwisaf.Service;

import android.app.Notification;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.IBinder;

import com.cysecurity.darwisaf.AppInstallReceiver;

public class AppInstallService extends Service {
    private AppInstallReceiver receiver;

    @Override
    public void onCreate() {
        super.onCreate();
        receiver = new AppInstallReceiver();
        IntentFilter filter = new IntentFilter(Intent.ACTION_PACKAGE_ADDED);
        filter.addDataScheme("package");
        registerReceiver(receiver, filter);
//        startForeground(1, new Notification()); // Start the service in foreground mode
    }

    @Override
    public IBinder onBind(Intent intent) {
        // Not needed for this implementation
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        unregisterReceiver(receiver); // Unregister the receiver when the service is destroyed
    }
}
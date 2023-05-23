package com.cysecurity.darwisaf.Service;

import android.app.Service;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.IBinder;

import com.cysecurity.darwisaf.AppUninstallReceiver;

public class AppUninstallService extends Service {
    private AppUninstallReceiver receiver;

    @Override
    public void onCreate() {
        super.onCreate();
        receiver = new AppUninstallReceiver();
        IntentFilter filter = new IntentFilter(Intent.ACTION_PACKAGE_FULLY_REMOVED);
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
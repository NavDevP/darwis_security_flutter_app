package com.shanu.secure.cysecurity;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class AppInstallReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_PACKAGE_ADDED.equals(intent.getAction())) {
            String packageName = intent.getData().getSchemeSpecificPart();
            Intent intent2 = new Intent("com.shanu.secure.cysecurity.AppInstallReceiver");
            intent2.putExtra("package", packageName);
            context.sendBroadcast(intent2);
        }
    }
}

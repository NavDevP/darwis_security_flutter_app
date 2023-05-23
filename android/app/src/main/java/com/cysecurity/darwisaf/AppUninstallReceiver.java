package com.cysecurity.darwisaf;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class AppUninstallReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        System.out.println(intent.getAction());
        if (Intent.ACTION_PACKAGE_FULLY_REMOVED.equals(intent.getAction())) {
            String packageName = intent.getData().getSchemeSpecificPart();
            Intent intent2 = new Intent("com.cysecurity.darwisaf.AppUninstallReceiver");
            intent2.putExtra("package", packageName);
            context.sendBroadcast(intent2);
        }
    }
}

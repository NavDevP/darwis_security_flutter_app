package com.cysecurity.darwisaf;

import io.flutter.embedding.android.FlutterActivity;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;

import com.cysecurity.darwisaf.Service.AppInstallService;
import com.cysecurity.darwisaf.Service.AppUninstallService;

public class MainActivity extends FlutterActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent intent = new Intent(this, AppInstallService.class);
        startService(intent);

        Intent intent2 = new Intent(this, AppUninstallService.class);
        startService(intent2);
    }

    @Override
    public void onDestroy() {

        try{
            AppInstallReceiver receiver = new AppInstallReceiver();
            unregisterReceiver(receiver);

            AppUninstallReceiver receiver2 = new AppUninstallReceiver();
            unregisterReceiver(receiver2);

        }catch(Exception exception){
            System.out.println(exception.getMessage());
        }

        super.onDestroy();
    }

}

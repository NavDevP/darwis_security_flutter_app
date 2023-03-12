package com.cysecurity.fingerprint

import android.content.Context
import android.content.Intent
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import android.content.pm.PackageManager
import android.content.pm.Signature
import java.security.NoSuchAlgorithmException;
import android.net.Uri
import android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS
import android.widget.Toast
import android.widget.Toast.LENGTH_LONG
import android.widget.Toast.LENGTH_SHORT
import com.cysecurity.fingerprint.Util.Companion.convertAppToMap
import com.cysecurity.fingerprint.Util.Companion.getPackageManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.Locale.ENGLISH
import java.io.FileInputStream
import java.security.MessageDigest
import java.util.Locale

class InstalledAppsPlugin() : MethodCallHandler, FlutterPlugin, ActivityAware {

    companion object {

        var context: Context? = null

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            context = registrar.context()
            register(registrar.messenger())
        }

        @JvmStatic
        fun register(messenger: BinaryMessenger) {
            val channel = MethodChannel(messenger, "fingerprint")
            channel.setMethodCallHandler(InstalledAppsPlugin())
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        InstalledAppsPlugin.register(binding.getBinaryMessenger())
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }

    override fun onAttachedToActivity(activityPluginBinding: ActivityPluginBinding) {
        context = activityPluginBinding.getActivity()
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(activityPluginBinding: ActivityPluginBinding) {
        context = activityPluginBinding.getActivity()
    }

    override fun onDetachedFromActivity() {}

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (context == null) {
            result.error("", "Something went wrong!", null)
            return
        }
        when (call.method) {
            "getInstalledApps" -> {
                val includeSystemApps = call.argument("exclude_system_apps") ?: true
                val withIcon = call.argument("with_icon") ?: false
                val packageNamePrefix: String = call.argument("package_name_prefix") ?: ""
                Thread {
                    val apps: List<Map<String, Any?>> =
                        getInstalledApps(includeSystemApps, withIcon, packageNamePrefix)
                    result.success(apps)
                }.start()
            }
            "startApp" -> {
                val packageName: String? = call.argument("package_name")
                result.success(startApp(packageName))
            }
            "openSettings" -> {
                val packageName: String? = call.argument("package_name")
                openSettings(packageName)
            }
            "toast" -> {
                val message = call.argument("message") ?: ""
                val short = call.argument("short_length") ?: true
                toast(message, short)
            }
            "getAppInfo" -> {
                val packageName: String = call.argument("package_name") ?: ""
                result.success(getAppInfo(getPackageManager(context!!), packageName))
            }
            "isSystemApp" -> {
                val packageName: String = call.argument("package_name") ?: ""
                result.success(isSystemApp(getPackageManager(context!!), packageName))
            }
            "getSha" -> {
                val packageName: String = call.argument("package_name") ?: ""
                result.success(getSha(getPackageManager(context!!), packageName))
            }
            else -> result.notImplemented()
        }
    }

    private fun getInstalledApps(
        excludeSystemApps: Boolean,
        withIcon: Boolean,
        packageNamePrefix: String
    ): List<Map<String, Any?>> {
        val packageManager = getPackageManager(context!!)
        var installedApps = packageManager.getInstalledApplications(0)
        if (excludeSystemApps)
            installedApps =
                installedApps.filter { app -> !isSystemApp(packageManager, app.packageName) }
        if (packageNamePrefix.isNotEmpty())
            installedApps = installedApps.filter { app ->
                app.packageName.startsWith(
                    packageNamePrefix.lowercase(ENGLISH)
                )
            }
        return installedApps.map { app -> convertAppToMap(packageManager, app, withIcon) }
    }

    private fun startApp(packageName: String?): Boolean {
        if (packageName.isNullOrBlank()) return false
        return try {
            val launchIntent = getPackageManager(context!!).getLaunchIntentForPackage(packageName)
            context!!.startActivity(launchIntent)
            true
        } catch (e: Exception) {
            print(e)
            false
        }
    }

    private fun toast(text: String, short: Boolean) {
        Toast.makeText(context!!, text, if (short) LENGTH_SHORT else LENGTH_LONG)
            .show()
    }

    private fun isSystemApp(packageManager: PackageManager, packageName: String): Boolean {
        return packageManager.getLaunchIntentForPackage(packageName) == null
    }

    private fun openSettings(packageName: String?) {
        val intent = Intent()
        intent.flags = FLAG_ACTIVITY_NEW_TASK
        intent.action = ACTION_APPLICATION_DETAILS_SETTINGS
        val uri = Uri.fromParts("package", packageName, null)
        intent.data = uri
        context!!.startActivity(intent)
    }

    private fun getAppInfo(
        packageManager: PackageManager,
        packageName: String
    ): Map<String, Any?>? {
        var installedApps = packageManager.getInstalledApplications(0)
        installedApps = installedApps.filter { app -> app.packageName == packageName }
        return if (installedApps.isEmpty()) null
        else convertAppToMap(packageManager, installedApps[0], true)
    }

    private fun getHash(filePath: String): String {
        val digest = MessageDigest.getInstance("SHA-256")
        val fis = FileInputStream(filePath)
        val byteArray = ByteArray(1024)
        var bytesCount = 0
        while (fis.read(byteArray).also { bytesCount = it } != -1) {
            digest.update(byteArray, 0, bytesCount)
        }
        fis.close()
        val bytes = digest.digest()
        val sb = StringBuilder()
        for (i in bytes.indices) {
            sb.append(Integer.toString((bytes[i].toInt() and 0xff) + 0x100, 16).substring(1))
        }
        return sb.toString()
    }


//    private fun getSha(packageManager: PackageManager, packageName: String) {
    private fun getSha(packageManager: PackageManager, packageName: String): String {
        try {
            var installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
            installedApps = installedApps.filter { app -> app.packageName == packageName }
//            println(installedApps[0].publicSourceDir);
//            if (packagelist.size > 0) {
//                for (i in 0 until packagelist.size) {
//                    var file = File(installedApps[0].publicSourceDir);
//                }
//            }
            val hash = getHash(installedApps[0].publicSourceDir)
            return hash.toString();
        } catch (e: Exception) {
            return "Error";
            e.printStackTrace()
        }
//        println("Package: " + packageName)
        // Firngerprint Function
//        val sigs: Array<Signature> = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES).signingInfo.getApkContentsSigners()
////        for (sig in sigs) {
//            val cert: ByteArray = sigs.get(0).toByteArray()
//            var sha = byte2hex(computeHash(cert, "sha256"))
//            if(sha != null) {
////                println(
////                    "Signature hashcode1 : " + sha.trim().replace(" ", ":").toUpperCase(Locale.US)
////                )
//                return sha.trim().replace(" ", ":").toUpperCase(Locale.US);
//            }
//        return "No Fingerprint";
    //End Fingerprint Function
//        }
    }

    private fun computeHash(data: ByteArray?, hashType: String?): ByteArray? {
        return try {
            MessageDigest.getInstance(hashType).digest(data)
        } catch (e: NoSuchAlgorithmException) {
            null
        }
    }

    private fun byte2hex(data: ByteArray?): String? {
        if (data == null) {
            return null
        }
        val sb = StringBuilder()
        var i = 1
        for (b in data) {
            if (i == 0) {
                sb.append(' ')
                i = 1
            }
            i--
            val byteData: Int = b.toInt() and 255
            val s: String = Integer.toString(byteData, 16)
            if (byteData < 16) {
                sb.append("0")
            }
            sb.append(s)
        }
        return sb.toString()
    }

}

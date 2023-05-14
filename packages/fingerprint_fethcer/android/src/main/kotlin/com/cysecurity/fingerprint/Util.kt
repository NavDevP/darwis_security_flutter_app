package com.cysecurity.fingerprint

import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build.VERSION.SDK_INT
import android.os.Build.VERSION_CODES.N_MR1
import android.os.Build.VERSION_CODES.P
import java.io.ByteArrayOutputStream

import java.io.FileInputStream
import java.security.MessageDigest
import java.util.Locale

class Util {

    companion object {

        fun convertAppToMap(
            packageManager: PackageManager,
            app: ApplicationInfo,
            withIcon: Boolean,
            sha256: Boolean=false,
            md5: Boolean=false,
        ): HashMap<String, Any?> {
            val map = HashMap<String, Any?>()
            map["name"] = packageManager.getApplicationLabel(app)
            map["package_name"] = app.packageName
            map["icon"] = if (withIcon) drawableToByteArray(app.loadIcon(packageManager)) else ByteArray(0)
            val packageInfo = packageManager.getPackageInfo(app.packageName, 0)
            map["version_name"] = packageInfo.versionName
            map["version_code"] = getVersionCode(packageInfo)
            if(sha256)
                map["sha256"] = getSha(packageManager,app.packageName,"SHA-256")
            if(md5)
                map["md5"] = getSha(packageManager,app.packageName,"MD5")
            return map
        }

        private fun drawableToByteArray(drawable: Drawable): ByteArray {
            val bitmap = drawableToBitmap(drawable)
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            return stream.toByteArray()
        }

        private fun drawableToBitmap(drawable: Drawable): Bitmap {
            if (SDK_INT <= N_MR1) return (drawable as BitmapDrawable).bitmap
            val bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth,
                drawable.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            return bitmap
        }

        fun getPackageManager(context: Context): PackageManager {
            return context.packageManager
        }

        @Suppress("DEPRECATION")
        private fun getVersionCode(packageInfo: PackageInfo): Long {
            return if (SDK_INT < P) packageInfo.versionCode.toLong()
            else packageInfo.longVersionCode
        }


        private fun getHash(filePath: String, instanceType: String): String {
            val digest = MessageDigest.getInstance(instanceType)
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

        private fun getSha(packageManager: PackageManager, packageName: String, instanceType: String): String {
            try {
                var installedApps = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)
                installedApps = installedApps.filter { app -> app.packageName == packageName }

                val hash = getHash(installedApps[0].publicSourceDir,instanceType)
                return hash.toString();
            } catch (e: Exception) {
                return "Error";
                e.printStackTrace()
            }
        }

    }

}
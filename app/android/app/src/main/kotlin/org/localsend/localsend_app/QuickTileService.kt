package org.localsend.localsend_app

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log
import androidx.annotation.RequiresApi

/**
 * Quick settings tile to quickly open LocalSend and show keep-alive status.
 */
@RequiresApi(Build.VERSION_CODES.N)
class QuickTileService : TileService() {
    companion object {
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val KEEP_ALIVE_KEY = "flutter.ls_background_keep_alive"
    }

    override fun onClick() {
        super.onClick()
        launchApp()
    }

    override fun onStartListening() {
        super.onStartListening()
        updateTileState()
    }

    private fun updateTileState() {
        if (qsTile == null) {
            return
        }

        val keepAliveEnabled = isKeepAliveEnabled()
        qsTile.icon = Icon.createWithResource(this, R.mipmap.ic_launcher_quicktile_foreground)
        qsTile.label = packageManager.getApplicationLabel(application.applicationInfo)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            qsTile.subtitle = if (keepAliveEnabled) {
                getString(R.string.quick_tile_keep_alive_active)
            } else {
                getString(R.string.quick_tile_keep_alive_inactive)
            }
        }
        qsTile.state = if (keepAliveEnabled || KeepAliveService.isRunning) {
            Tile.STATE_ACTIVE
        } else {
            Tile.STATE_INACTIVE
        }
        qsTile.updateTile()
    }

    private fun isKeepAliveEnabled(): Boolean {
        val prefs = applicationContext.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
        return prefs.getBoolean(KEEP_ALIVE_KEY, false)
    }

    @SuppressLint("StartActivityAndCollapseDeprecated")
    private fun launchApp() {
        try {
            val launchIntent = getLaunchIntent()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                startActivityAndCollapse(
                    PendingIntent.getActivity(
                        this,
                        0,
                        launchIntent,
                        PendingIntent.FLAG_IMMUTABLE,
                    ),
                )
            } else {
                startActivityAndCollapse(launchIntent)
            }
        } catch (e: Exception) {
            Log.w(this.javaClass.toString(), "Exception $e")
        }
    }

    private fun getLaunchIntent(): Intent {
        val cleanIntent = packageManager.getLaunchIntentForPackage(packageName)

        return if (cleanIntent != null) {
            cleanIntent
        } else {
            val dirtyIntent = MainActivity.createDefaultIntent(this)
            dirtyIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            dirtyIntent
        }
    }

    @Suppress("unused")
    private fun appIsAlreadyRunning(): Boolean {
        val info = ActivityManager.RunningAppProcessInfo()
        ActivityManager.getMyMemoryState(info)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            info.importance != ActivityManager.RunningAppProcessInfo.IMPORTANCE_CACHED
        } else {
            info.importance != ActivityManager.RunningAppProcessInfo.IMPORTANCE_BACKGROUND
        }
    }
}
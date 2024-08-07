package com.pravera.flutter_foreground_task.service

import com.pravera.flutter_foreground_task.models.NotificationPermission

interface NotificationPermissionCallback {
    fun onResult(permissionStatus: NotificationPermission)
    fun onError(exception: Exception)
}

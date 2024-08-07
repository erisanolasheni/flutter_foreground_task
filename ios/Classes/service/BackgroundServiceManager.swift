//
//  BackgroundServiceManager.swift
//  flutter_foreground_task
//
//  Created by WOO JIN HWANG on 2021/08/10.
//

import Flutter
import Foundation

class BackgroundServiceManager: NSObject {
  func start(arguments: Any?) throws {
    if #available(iOS 10.0, *) {
      if BackgroundService.sharedInstance.isRunningService {
        throw ServiceError.ServiceAlreadyStartedException
      }
 
      saveOptions(arguments: arguments)
      BackgroundService.sharedInstance.run(action: BackgroundServiceAction.START)
    } else {
      throw ServiceError.ServiceNotSupportedException
    }
  }
  
  func restart(arguments: Any?) throws {
    if #available(iOS 10.0, *) {
      if !BackgroundService.sharedInstance.isRunningService {
        throw ServiceError.ServiceNotStartedException
      }
      
      BackgroundService.sharedInstance.run(action: BackgroundServiceAction.RESTART)
    } else {
      throw ServiceError.ServiceNotSupportedException
    }
  }
  
  func update(arguments: Any?) throws {
    if #available(iOS 10.0, *) {
      if !BackgroundService.sharedInstance.isRunningService {
        throw ServiceError.ServiceNotStartedException
      }
      
      updateOptions(arguments: arguments)
      BackgroundService.sharedInstance.run(action: BackgroundServiceAction.UPDATE)
    } else {
      throw ServiceError.ServiceNotSupportedException
    }
  }
  
  func stop() throws {
    if #available(iOS 10.0, *) {
      if !BackgroundService.sharedInstance.isRunningService {
        throw ServiceError.ServiceNotStartedException
      }
      
      clearOptions()
      BackgroundService.sharedInstance.run(action: BackgroundServiceAction.STOP)
    } else {
      throw ServiceError.ServiceNotSupportedException
    }
  }
  
  func sendData(data: Any?) {
    if data != nil {
      BackgroundService.sharedInstance.sendData(data: data)
    }
  }
  
  func isRunningService() -> Bool {
    if #available(iOS 10.0, *) {
      return BackgroundService.sharedInstance.isRunningService
    } else {
      return false
    }
  }
  
  private func saveOptions(arguments: Any?) {
    guard let argsDict = arguments as? Dictionary<String, Any> else { return }
    let prefs = UserDefaults.standard

    // notification options
    let showNotification = argsDict[SHOW_NOTIFICATION] as? Bool ?? true
    let playSound = argsDict[PLAY_SOUND] as? Bool ?? false

    // background task options
    let taskInterval = argsDict[TASK_INTERVAL] as? Int ?? 5000
    let isOnceEvent = argsDict[IS_ONCE_EVENT] as? Bool ?? false

    // background task data
    let callbackHandle = argsDict[CALLBACK_HANDLE] as? Int64

    // notification content
    let notificationContentTitle = argsDict[NOTIFICATION_CONTENT_TITLE] as? String ?? ""
    let notificationContentText = argsDict[NOTIFICATION_CONTENT_TEXT] as? String ?? ""

    prefs.set(showNotification, forKey: SHOW_NOTIFICATION)
    prefs.set(playSound, forKey: PLAY_SOUND)
    prefs.set(taskInterval, forKey: TASK_INTERVAL)
    prefs.set(isOnceEvent, forKey: IS_ONCE_EVENT)
    prefs.removeObject(forKey: CALLBACK_HANDLE)
    if callbackHandle != nil {
      prefs.set(callbackHandle, forKey: CALLBACK_HANDLE)
    }
    prefs.set(notificationContentTitle, forKey: NOTIFICATION_CONTENT_TITLE)
    prefs.set(notificationContentText, forKey: NOTIFICATION_CONTENT_TEXT)
  }
  
  private func updateOptions(arguments: Any?) {
    guard let argsDict = arguments as? Dictionary<String, Any> else { return }
    let prefs = UserDefaults.standard

    // background task options
    let taskInterval = argsDict[TASK_INTERVAL] as? Int
    let isOnceEvent = argsDict[IS_ONCE_EVENT] as? Bool

    // background task data
    let callbackHandle = argsDict[CALLBACK_HANDLE] as? Int64

    // notification content
    let notificationContentTitle = argsDict[NOTIFICATION_CONTENT_TITLE] as? String
      ?? prefs.string(forKey: NOTIFICATION_CONTENT_TITLE)
      ?? ""
    let notificationContentText = argsDict[NOTIFICATION_CONTENT_TEXT] as? String
      ?? prefs.string(forKey: NOTIFICATION_CONTENT_TEXT)
      ?? ""

    if taskInterval != nil {
      prefs.set(taskInterval, forKey: TASK_INTERVAL)
    }
    if isOnceEvent != nil {
      prefs.set(isOnceEvent, forKey: IS_ONCE_EVENT)
    }
    if callbackHandle != nil {
      prefs.set(callbackHandle, forKey: CALLBACK_HANDLE)
    }
    prefs.set(notificationContentTitle, forKey: NOTIFICATION_CONTENT_TITLE)
    prefs.set(notificationContentText, forKey: NOTIFICATION_CONTENT_TEXT)
  }
  
  private func clearOptions() {
    let prefs = UserDefaults.standard
    prefs.removeObject(forKey: SHOW_NOTIFICATION)
    prefs.removeObject(forKey: PLAY_SOUND)
    prefs.removeObject(forKey: TASK_INTERVAL)
    prefs.removeObject(forKey: IS_ONCE_EVENT)
    prefs.removeObject(forKey: CALLBACK_HANDLE)
    prefs.removeObject(forKey: NOTIFICATION_CONTENT_TITLE)
    prefs.removeObject(forKey: NOTIFICATION_CONTENT_TEXT)
  }
  
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    BackgroundService.sharedInstance
      .userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
  }
  
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    BackgroundService.sharedInstance
      .userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
  }
}

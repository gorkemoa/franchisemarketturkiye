//
//  NotificationService.swift
//  NotificationService
//
//  Created by admin on 2.02.2026.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Log for debugging (can be seen in device logs)
            print("Notification received with userInfo: \(bestAttemptContent.userInfo)")
            
            var imageUrlString: String? = nil
            
            // 1. Check for image in fcm_options (Common in V1 API)
            if let fcmOptions = bestAttemptContent.userInfo["fcm_options"] as? [String: Any],
               let image = fcmOptions["image"] as? String {
                imageUrlString = image
            }
            
            // 2. Check for image in top-level (Common in Legacy API or many wrappers)
            if imageUrlString == nil {
                imageUrlString = bestAttemptContent.userInfo["image"] as? String
            }
            
            // 3. Check for image in gcm.notification.image (Standard FCM)
            if imageUrlString == nil {
                imageUrlString = bestAttemptContent.userInfo["gcm.notification.image"] as? String
            }
            
            // 4. Check for other possible keys
            if imageUrlString == nil {
                imageUrlString = bestAttemptContent.userInfo["image-url"] as? String ?? 
                               bestAttemptContent.userInfo["image_url"] as? String ??
                               bestAttemptContent.userInfo["attachment-url"] as? String
            }

            if let imageUrlString = imageUrlString, let imageUrl = URL(string: imageUrlString) {
                downloadImage(url: imageUrl) { (attachment) in
                    if let attachment = attachment {
                        bestAttemptContent.attachments = [attachment]
                    }
                    contentHandler(bestAttemptContent)
                }
            } else {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    private func downloadImage(url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (temporaryFileLocation, response, error) in
            guard let temporaryFileLocation = temporaryFileLocation, error == nil else {
                completion(nil)
                return
            }
            
            let fileManager = FileManager.default
            let extensionName = url.pathExtension.isEmpty ? "png" : url.pathExtension
            
            // Create a temporary file with the correct extension
            let temporaryDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
                .appendingPathExtension(extensionName)
            
            do {
                try fileManager.moveItem(at: temporaryFileLocation, to: temporaryDirectory)
                let attachment = try UNNotificationAttachment(identifier: "", url: temporaryDirectory, options: nil)
                completion(attachment)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

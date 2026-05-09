//
//  BackgroundTaskManager.swift
//  Chiari Research App
//

import BackgroundTasks
import FirebaseAuth
import Foundation

class BackgroundTaskManager {
    static let taskIdentifier = "com.chiari.pressureCollection"
    
    // MARK: - Register Handler
    /// Call this once on app launch to register the background task handler
    static func registerBackgroundTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            handlePressureCollection(task: task as! BGAppRefreshTask)
        }
        print("✓ Background task registered")
    }
    
    // MARK: - Schedule Task
    /// Schedule the next background task (call after successful login)
    static func schedulePressureCollection() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 10 * 60)  // 10 minutes from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("✓ Background task scheduled for 10 minutes from now")
        } catch {
            print("✗ Failed to schedule background task: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Handle Collection
    /// Called by iOS when it's time to collect pressure data
    private static func handlePressureCollection(task: BGAppRefreshTask) {
        print("🔄 Background task running at \(Date())")
        
        // Set expiration handler in case iOS stops us early
        task.expirationHandler = {
            print("⏱ Background task expired - stopping")
            task.setTaskCompleted(success: false)
        }
        
        // Check if user is still logged in
        guard isUserLoggedIn() else {
            print("⚠ User not logged in - skipping collection")
            task.setTaskCompleted(success: true)
            return
        }
        
        Task {
            do {
                // TODO: Collect pressure data
                print("📊 Collecting pressure data...")
                
                // TODO: Store locally if offline
                print("💾 Storing data locally...")
                
                // TODO: Sync to server if online
                print("☁️ Syncing to server...")
                
                // Reschedule for next collection
                schedulePressureCollection()
                
                // Mark task complete
                task.setTaskCompleted(success: true)
                print("✅ Background task completed successfully")
            } catch {
                print("❌ Background task failed: \(error.localizedDescription)")
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    // MARK: - Helpers
    /// Check if a user is currently logged in
    private static func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}

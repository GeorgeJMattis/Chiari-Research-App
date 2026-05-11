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
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60)  // 1 minute from now (use 10 * 60 for production)
        
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
        print("Background task running at \(Date())")
        
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
                // Get the stored uid — Firebase Auth may not be ready on background wake
                guard let uid = UserDefaults.standard.string(forKey: "currentUserUID") else {
                    print("⚠ No stored uid - skipping collection")
                    task.setTaskCompleted(success: true)
                    return
                }

                // Collect sensor data and save locally
                print("📊 Collecting pressure data...")
                let sensorService = SensorService()
                try await sensorService.collectAndSave(uid: uid)
                print("💾 Batch saved locally")

                // Sync any unsynced batches if online
                if NetworkService.shared.isConnected {
                    print("☁️ Syncing unsynced batches to Firestore...")
                    let localRepo = LocalSensorRepository()
                    let firebaseRepo = FirebaseSensorRepository()
                    let unsyncedBatches = try await localRepo.fetchUnsyncedBatches()

                    for batch in unsyncedBatches {
                        try await firebaseRepo.saveBatch(batch)
                        try await localRepo.markBatchAsSynced(batchID: batch.id)
                    }
                    print("✅ Synced \(unsyncedBatches.count) batch(es)")
                } else {
                    print("📵 Offline - batches will sync later")
                }

                // Reschedule for next collection
                schedulePressureCollection()
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

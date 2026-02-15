import Foundation

enum SyncError: Error {
    case network
    case server
    case unknown
}

actor SyncQueue {
    
    // Logic Spec: Retry Policy
    private let maxRetries = 3
    private let initialBackoff: TimeInterval = 1.0 // Start at 1 second
    
    private var tasks: [(UUID, () async throws -> Void)] = []
    
    /// Adds a task to the queue and processes it.
    /// - Parameter task: The sync operation to perform.
    func enqueue(task: @escaping () async throws -> Void) {
        let id = UUID()
        tasks.append((id, task))
        Task {
            await processQueue()
        }
    }
    
    /// Process the queue one by one with retry logic.
    private func processQueue() async {
        while !tasks.isEmpty {
            let (id, task) = tasks.removeFirst()
            
            do {
                try await executeWithRetry(task: task)
                print("Task \(id) synced successfully.")
            } catch {
                print("Task \(id) failed after \(maxRetries) retries. Error: \(error)")
                // Depending on strategy, we might want to re-queue or discard.
                // Spec says "queue_based", implying strict ordering or persistence.
                // For this implementation, we log failure and move on to unblock the queue.
            }
        }
    }
    
    /// Executes a task with exponential backoff retry logic.
    /// - Parameter task: The async closure to execute.
    private func executeWithRetry(task: () async throws -> Void) async throws {
        var attempt = 0
        var currentBackoff = initialBackoff
        
        while attempt <= maxRetries {
            do {
                try await task()
                return // Success
            } catch {
                attempt += 1
                if attempt > maxRetries {
                    throw error
                }
                
                print("Retry attempt \(attempt) for task. Backing off for \(currentBackoff) seconds.")
                // Exponential Backoff
                try? await Task.sleep(nanoseconds: UInt64(currentBackoff * 1_000_000_000))
                currentBackoff *= 2
            }
        }
    }
}

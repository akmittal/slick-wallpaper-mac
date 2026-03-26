import Foundation
import Combine

// MARK: - SchedulerService

final class SchedulerService {
    static let shared = SchedulerService()

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init() {
        // React to interval changes
        UserSettings.shared.$interval
            .dropFirst()
            .sink { [weak self] _ in
                self?.restart()
            }
            .store(in: &cancellables)

        start()
    }

    func start() {
        let interval = UserSettings.shared.interval.seconds
        scheduleTimer(interval: interval)
    }

    func restart() {
        timer?.invalidate()
        start()
    }

    private func scheduleTimer(interval: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            DispatchQueue.main.async {
                WallpaperPipeline.shared.generateAndApply()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
        print("[Scheduler] Next wallpaper in \(interval / 3600)h")
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}

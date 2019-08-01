import Foundation

protocol PomodoroTimerDelegate: AnyObject {

    func pomodoroTimerStart(_ timer: PomodoroTimer)
    func pomodoroTimerPause(_ timer: PomodoroTimer)
    func pomodoroTimerStop(_ timer: PomodoroTimer)
    func pomodoroTimerTick(_ timer: PomodoroTimer)

}

// MARK: -

class PomodoroTimer: NSObject {

    // MARK: - Subtypes

    enum Phase: Equatable {
        case work
        case rest
        case none

        var duration: Int {
            switch self {
            case .work:
                return 25 * 60
            case .rest:
                return 5 * 60
            case .none:
                return 0
            }
        }
    }

    // MARK: - Properties

    weak var delegate: PomodoroTimerDelegate?

    private(set) var phase: Phase = .none {
        didSet {
            let newValue = phase
            guard oldValue != newValue else { return }

            time = newValue.duration
            delegate?.pomodoroTimerTick(self)

            timer?.invalidate()
            timer = nil

            switch (oldValue, newValue) {
            case (.none, .work), (.work, .rest), (.rest, .work):
                timer = Timer.scheduledTimer(
                    timeInterval: 1,
                    target: self,
                    selector: #selector(tick),
                    userInfo: nil,
                    repeats: true
                )
                delegate?.pomodoroTimerStart(self)
            case (.work, .none), (.rest, .none):
                delegate?.pomodoroTimerStop(self)
            default:
                assertionFailure("Unexpected behavior")
            }
        }
    }

    private var timer: Timer?
    private(set) var time = 0

    // MARK: - Implementation

    func start() {
        switch phase {
        case .none, .rest:
            phase = .work
        case .work:
            phase = .rest
        }
    }

    func stop() {
        phase = .none
    }

    @objc
    private func tick() {
        time -= 1
        if time >= 0 {
            delegate?.pomodoroTimerTick(self)
        } else {
            delegate?.pomodoroTimerPause(self)
            timer?.invalidate()
            timer = nil
        }
    }

}

import Cocoa

class ViewController: NSViewController {
    
    // MARK: - Subviews
    
    @IBOutlet private var touchBarItem: NSTouchBarItem!
    @IBOutlet private var touchButton: TouchButton!
    
    // MARK: - Properties
    
    private let timer = PomodoroTimer()
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        touchButton.delegate = self
        timer.delegate = self

        NSTouchBarItem.addSystemTrayItem(touchBarItem)
        DFRElementSetControlStripPresenceForIdentifier(touchBarItem.identifier, true)
    }
    
}

// MARK: - PomodoroTimerDelegate

extension ViewController: PomodoroTimerDelegate {

    func pomodoroTimerStart(_ timer: PomodoroTimer) {
        touchButton.imagePosition = .noImage
        switch timer.phase {
        case .work:
            touchButton.bezelColor = .systemRed
        case .rest:
            touchButton.bezelColor = .systemGreen
        default:
            assertionFailure("Unexpected behavior")
        }
    }

    func pomodoroTimerPause(_ timer: PomodoroTimer) {
        NSSound(named: NSSound.Name("Basso"))?.play()
    }

    func pomodoroTimerStop(_ timer: PomodoroTimer) {
        touchButton.imagePosition = .imageOnly
        touchButton.bezelColor = .clear
        touchButton.title = ""
    }

    func pomodoroTimerTick(_ timer: PomodoroTimer) {
        touchButton.title = String(format: "%.2i:%.2i", timer.time / 60, timer.time % 60)
    }

}

// MARK: - TouchButtonDelegate

extension ViewController: TouchButtonDelegate {
    
    func touchButtonTap(_ button: TouchButton) {
        guard timer.time <= 0 else { return }
        timer.start()
    }
    
    func touchButtonDoubleTap(_ button: TouchButton) {
        timer.stop()
    }

    func touchButtonTapAndHold(_ button: TouchButton) {
        exit(0)
    }
    
}

"""INF-482 Bugbot/Cursor webhook capture probe.

This file is intentionally not imported by the app. It contains a very
obvious benign bug so PR review automation has something safe to notice.
Do not merge this PR; close it after webhook/event-shape capture.
"""


def percent_available(used: int, total: int) -> float:
    """Return available capacity as a percentage.

    Intentional benign bug for INF-482 capture: this returns the used
    percentage instead of the available percentage. For used=25,total=100,
    it returns 25.0 but should return 75.0.
    """
    if total <= 0:
        return 0.0
    return (used / total) * 100


if __name__ == "__main__":
    print(percent_available(25, 100))

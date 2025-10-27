module timer;

import std.conv : to;
import std.string, std.range;
import std.datetime;
import atelier;

private {
    TimerUI _timerUI;
}

void startTime() {
    if (!_timerUI) {
        _timerUI = new TimerUI();
        Atelier.ui.addUI(_timerUI);
    }
}

void removeTime() {
    _timerUI = null;
}

void pauseTime() {
    if (!_timerUI)
        return;

    _timerUI.pauseTime();
}

void resumeTime() {
    if (!_timerUI)
        return;

    _timerUI.resumeTime();
}

void resetTime() {
    if (!_timerUI)
        return;

    _timerUI.resetTime();
}

string getTotalTime() {
    if (!_timerUI)
        return "";

    return _timerUI.getTime();
}

final class TimerUI : UIElement {
    private {
        Label _label;
        MonoTime _startTime;
        Duration _currentTime, _lastTime;
        bool _isRunning = true;
    }

    this() {
        _timerUI = this;

        setAlign(UIAlignX.right, UIAlignY.top);
        setPosition(Vec2f(10f, 10f));

        import atelier.core.data.vera : veraMonoFontData;

        Font font = TrueTypeFont.fromMemory(veraMonoFontData, 16, 1);

        _label = new Label("", font);
        _label.textColor = lerp(Color.cyan, Color.white, 0.95f);
        addUI(_label);
        setSize(_label.getSize());

        _startTime = MonoTime.currTime();

        addEventListener("update", &_onUpdate);
    }

    void pauseTime() {
        if (!_isRunning)
            return;

        _lastTime = _currentTime;
        _startTime = MonoTime.currTime();
        _isRunning = false;
    }

    void resumeTime() {
        if (_isRunning)
            return;

        _startTime = MonoTime.currTime();
        _isRunning = true;
    }

    void resetTime() {
        _startTime = MonoTime.currTime();
        _currentTime = Duration.zero;
        _lastTime = Duration.zero;
        _isRunning = true;
    }

    private void _onUpdate() {
        if (_isRunning) {
            _currentTime = (MonoTime.currTime() - _startTime) + _lastTime;
        }

        _label.text = getTime();
        setSize(_label.getSize());
    }

    string getTime() {
        auto splittedTime = _currentTime.split();
        string msecsText = to!string(splittedTime.msecs);
        msecsText = to!string(msecsText.padRight('0', 3));
        string secsText = to!string(splittedTime.seconds);
        secsText = to!string(secsText.padLeft('0', 2));
        return to!string(_currentTime.total!"minutes"()) ~ ":" ~ secsText ~ ":" ~ msecsText;
    }
}

module victory;

import atelier;
import timer;
import menu;

final class Victory : UIElement {
    private {
        Timer _timer;
        int _step;
        Label _titleLabel;
        Label _text;
    }

    this() {
        pauseTime();
        Atelier.world.clear();
        setSize(cast(Vec2f) Atelier.renderer.size);

        setAlign(UIAlignX.left, UIAlignY.bottom);

        Sprite victory = Atelier.res.get!Sprite("victory");
        victory.anchor = Vec2f.zero;
        victory.position = Vec2f.zero;

        addImage(victory);

        string totalTime = getTotalTime();
        removeTime();

        import atelier.core.data.vera : veraMonoFontData;

        Font font = TrueTypeFont.fromMemory(veraMonoFontData, 20, 1);
        _titleLabel = new Label("Congratulations !!!", font);
        _text = new Label("Completion time: " ~ totalTime ~ " !!!", font);

        _timer.start(20);

        addEventListener("update", &_onUpdate);
    }

    private void _onUpdate() {
        _timer.update();

        if (!_timer.isRunning) {
            switch (_step) {
            case 0:
                _loadUI1();
                _step++;
                _timer.start(60);
                break;
            case 1:
                _loadUI2();
                _step++;
                _timer.start(100);
                break;
            case 2:
                _loadUI3();
                _step++;
                break;
            default:
                break;
            }
        }
    }

    private void _loadUI1() {
        State hiddenState = new State("hidden");
        hiddenState.offset = Vec2f(0f, -100f);
        hiddenState.scale = Vec2f(1f, 0f);
        hiddenState.alpha = 0f;
        addState(hiddenState);

        State visibleState = new State("visible");
        visibleState.spline = Spline.sineOut;
        visibleState.time = 60;
        addState(visibleState);

        _titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
        _titleLabel.setPosition(Vec2f(0f, 50f));
        _titleLabel.addState(hiddenState);
        _titleLabel.addState(visibleState);
        _titleLabel.setState("hidden");
        _titleLabel.runState("visible");
        addUI(_titleLabel);
    }

    private void _loadUI2() {
        State hiddenState = new State("hidden");
        hiddenState.offset = Vec2f(0f, -100f);
        hiddenState.scale = Vec2f(1f, 0f);
        hiddenState.alpha = 0f;
        addState(hiddenState);

        State visibleState = new State("visible");
        visibleState.spline = Spline.sineOut;
        visibleState.time = 60;
        addState(visibleState);

        _text.setAlign(UIAlignX.center, UIAlignY.center);
        _text.setPosition(Vec2f(0f, 0f));
        _text.addState(hiddenState);
        _text.addState(visibleState);
        _text.setState("hidden");
        _text.runState("visible");
        addUI(_text);
    }

    private void _loadUI3() {
        State hiddenState = new State("hidden");
        hiddenState.offset = Vec2f(-200f, 0f);
        hiddenState.alpha = 0f;
        addState(hiddenState);

        State visibleState = new State("visible");
        visibleState.spline = Spline.sineOut;
        visibleState.time = 60;
        addState(visibleState);

        MenuButton menuBtn = new MenuButton("Return to Menu");
        menuBtn.setAlign(UIAlignX.right, UIAlignY.bottom);
        menuBtn.setPosition(Vec2f(32f, 32f));
        menuBtn.addState(hiddenState);
        menuBtn.addState(visibleState);
        menuBtn.setState("hidden");
        menuBtn.runState("visible");
        addUI(menuBtn);
        menuBtn.addEventListener("click", {
            Atelier.ui.clearUI();
            Atelier.audio.play(new SoundPlayer(Atelier.res.get!Sound("menu_start")));
            Atelier.ui.addUI(new Menu);
        });
    }
}

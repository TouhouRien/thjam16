module menu;

import atelier;

final class Menu : UIElement {
    private {
        Timer _timer;
    }

    this() {
        setSize(cast(Vec2f) Atelier.renderer.size);

        addUI(new Title);
        addUI(new Sukuna);

        VBox vbox = new VBox;
        vbox.setAlign(UIAlignX.right, UIAlignY.bottom);
        vbox.setSpacing(4f);
        vbox.setPosition(Vec2f(64f, 4f));
        addUI(vbox);

        MenuButton startGameBtn = new MenuButton("Start Game");
        vbox.addUI(startGameBtn);
        startGameBtn.addEventListener("click", {
            Atelier.ui.clearUI();
            Atelier.world.load("level0_1");
        });

        MenuButton quitGameBtn = new MenuButton("Quit");
        vbox.addUI(quitGameBtn);
        quitGameBtn.addEventListener("click", {
            Atelier.ui.clearUI();
            Atelier.close();
        });
    }
}

final class Sukuna : UIElement {
    private {
        Sprite _sukuna;
    }

    this() {
        setAlign(UIAlignX.left, UIAlignY.bottom);
        isEnabled = false;

        _sukuna = Atelier.res.get!Sprite("shinmy_portrait");
        _sukuna.anchor = Vec2f.zero;
        _sukuna.position = Vec2f.zero;

        addImage(_sukuna);
        setSize(_sukuna.size);

        State initState = new State("init");
        initState.offset = Vec2f(-200f, 0f);
        addState(initState);

        State showState = new State("show");
        showState.spline = Spline.sineOut;
        showState.time = 60;
        addState(showState);

        setState("init");
        runState("show");

        addEventListener("update", {
            Vec2f offset = Vec2f.zero;
            Vec2f ratio = Atelier.input.getMousePosition() / cast(Vec2f) Atelier.renderer.size;
            offset.x = lerp(20f, -100f, ratio.x);
            offset.y = lerp(-20f, 0f, ratio.y);
            setPosition(offset);
        });
    }
}

final class Title : UIElement {
    private {
        Sprite _title;
    }

    this() {
        setAlign(UIAlignX.center, UIAlignY.top);
        isEnabled = false;

        _title = Atelier.res.get!Sprite("title");
        _title.anchor = Vec2f.zero;
        _title.position = Vec2f.zero;

        addImage(_title);
        setSize(_title.size);

        State initState = new State("init");
        initState.scale = Vec2f(1f, 0f);
        initState.alpha = 0f;
        addState(initState);

        State showState = new State("show");
        showState.spline = Spline.sineOut;
        showState.time = 60;
        addState(showState);

        setState("init");
        runState("show");

        addEventListener("update", {
            Vec2f offset = Vec2f.zero;
            Vec2f ratio = Atelier.input.getMousePosition() / cast(Vec2f) Atelier.renderer.size;
            offset.x = lerp(10f, -10f, ratio.x);
            offset.y = lerp(0f, -30f, ratio.y);
            setPosition(offset);
        });
    }
}

final class MenuButton : UIElement {
    private {
        Sprite _bg, _off, _on;
    }

    this(string text) {
        Sound sfx = Atelier.res.get!Sound("hover");

        _bg = Atelier.res.get!Sprite("button_bg");
        _bg.anchor = Vec2f(1f, 0.5f);
        _bg.size = _bg.size / 2f;
        addImage(_bg);

        _off = Atelier.res.get!Sprite("button_menu_off");
        _off.anchor = Vec2f(0f, 0.5f);
        addImage(_off);

        _on = Atelier.res.get!Sprite("button_menu_on");
        _on.anchor = Vec2f(0f, 0.5f);
        _on.isVisible = false;
        addImage(_on);

        Label label = new Label(text, Atelier.theme.font);
        label.setAlign(UIAlignX.right, UIAlignY.center);
        label.setPosition(Vec2f(10f, 0f));
        label.textColor = Color.black;
        addUI(label);

        setSize(Vec2f(180f, 64f));

        _bg.position = Vec2f(getWidth(), getHeight() / 2f);
        _off.position = Vec2f(0f, getHeight() / 2f);
        _on.position = Vec2f(0f, getHeight() / 2f);

        addEventListener("mouseenter", {
            _off.isVisible = false;
            _on.isVisible = true;
            _bg.alpha = 1f;
            Atelier.audio.play(new SoundPlayer(sfx, Atelier.rng.rand(0.6f, 1.2f)));
        });
        addEventListener("mouseleave", {
            _off.isVisible = true;
            _on.isVisible = false;
            _bg.alpha = 0.5f;
        });
    }
}

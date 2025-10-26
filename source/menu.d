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
        vbox.setAlign(UIAlignX.right, UIAlignY.center);
        vbox.setSpacing(16f);
        vbox.setPosition(Vec2f(64f, 64f));
        addUI(vbox);

        NeutralButton moncul = new NeutralButton("Démarrer con de jeu");
        vbox.addUI(moncul);
        moncul.addEventListener("click", {
            Atelier.ui.clearUI();
            Atelier.world.load("level0_5");
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

module victory;

import atelier;
import timer;
import menu;

final class Victory : UIElement {
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
        Label titleLabel = new Label("Congratulations !!!", font);
        Label text = new Label("Completion time: " ~ totalTime ~ " !!!", font);

        titleLabel.setAlign(UIAlignX.center, UIAlignY.top);
        titleLabel.setPosition(Vec2f(0f, 50f));
        addUI(titleLabel);

        text.setAlign(UIAlignX.center, UIAlignY.center);
        text.setPosition(Vec2f(0f, 0f));
        addUI(text);

        MenuButton menuBtn = new MenuButton("Return to Menu");
        menuBtn.setAlign(UIAlignX.right, UIAlignY.bottom);
        menuBtn.setPosition(Vec2f(32f, 32f));
        addUI(menuBtn);
        menuBtn.addEventListener("click", {
            Atelier.ui.clearUI();
            Atelier.audio.play(new SoundPlayer(Atelier.res.get!Sound("menu_start")));
            Atelier.ui.addUI(new Menu);
        });
    }
}

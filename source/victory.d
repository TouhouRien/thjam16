module victory;

import atelier;

final class Victory : UIElement {
    this() {
        setSize(cast(Vec2f) Atelier.renderer.size);

        setAlign(UIAlignX.left, UIAlignY.bottom);
        isEnabled = false;

        Sprite victory = Atelier.res.get!Sprite("victory");
        victory.anchor = Vec2f.zero;
        victory.position = Vec2f.zero;

        addImage(victory);
        setSize(victory.size);
    }
}
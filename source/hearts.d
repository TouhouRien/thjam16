module hearts;

import atelier;
import shinmy;

final class HeartsUI : UIElement {
    private {
        PlayerComponent _player;

        Sprite[] _sprites;
        uint _hearts = 0;
    }

    this(PlayerComponent player) {
        _player = player;
        setAlign(UIAlignX.left, UIAlignY.top);
        setPosition(Vec2f(8f, 8f));

        foreach (key; ["empty", "14", "half", "34", "full"]) {
            Sprite sprite = Atelier.res.get!Sprite("heart_" ~ key);
            sprite.anchor = Vec2f.zero;
            _sprites ~= sprite;
        }

        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
    }

    private void _onUpdate() {
        if (_hearts != _player.hearts) {
            _hearts = _player.hearts;
            setSize(Vec2f(16f * _hearts, 16f));
        }
    }

    private void _onDraw() {
        uint hearts = _player.hearts;
        uint nbFullHearts = _player.life / 4;
        uint heartId = _player.life % 4;

        Vec2f pos = Vec2f.zero;

        for (int i; i < hearts; ++i) {
            int id = 0;
            if (i < nbFullHearts) {
                id = 4;
            }
            else if (i == nbFullHearts) {
                id = heartId;
            }
            _sprites[id].draw(pos);

            pos.x += 16f;
        }
    }
}

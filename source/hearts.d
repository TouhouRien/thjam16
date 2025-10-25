module hearts;

import atelier;

final class PlayerComponent : EntityComponent {
    private {
        int _life, _maxLife;
    }

    void damage() {

    }

    override void setup() {
    }

    override void update() {
    }
}

final class HeartsUI : UIElement {
    private {
        PlayerComponent _player;

        Sprite[] _sprites;
    }

    this() {
        setAlign(UIAlignX.left, UIAlignY.top);

        foreach (key; ["empty", "14", "half", "34", "full"]) {
            Sprite sprite = Atelier.res.get!Sprite("heart_" ~ key);
            sprite.anchor = Vec2f.zero;
            _sprites ~= sprite;
        }

        addEventListener("update", &_onUpdate);
    }

    private void _onUpdate() {

    }

    private void _cache() {
        /* uint maxHearts = _player.maxLife / 4;
        uint nbFullHearts = _player.life / 4;
        uint heartId = _player.life % 4;

        for (int i; i < maxHearts; ++i) {
            int id = 0;
            if (i < nbFullHearts) {
                id = 4;
            }
            else if (i == nbFullHearts) {

            }
        }*/
    }
}

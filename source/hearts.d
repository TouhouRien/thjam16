module hearts;

import atelier;

final class PlayerComponent : EntityComponent {
    private {
        int _life, _maxLife;
    }

    @property {
        int life() const {
            return _life;
        }

        int maxLife() const {
            return _maxLife;
        }
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
        uint _maxLife = 0;
    }

    this() {
        setAlign(UIAlignX.left, UIAlignY.top);

        foreach (key; ["empty", "14", "half", "34", "full"]) {
            Sprite sprite = Atelier.res.get!Sprite("heart_" ~ key);
            sprite.anchor = Vec2f.zero;
            _sprites ~= sprite;
        }

        _player = Atelier.world.player().getComponent!PlayerComponent();

        _player._life = 12;
        _player._maxLife = 15;

        addEventListener("update", &_onUpdate);
        addEventListener("draw", &_onDraw);
    }

    private void _onUpdate() {
        if (_maxLife != _player.maxLife) {
            _maxLife = _player.maxLife;
            setSize(Vec2f((_sprites[0].width + 16f) * _maxLife, _sprites[0].height * 16f));
        }
    }

    private void _onDraw() {
        uint maxHearts = _player.maxLife / 5;
        uint nbFullHearts = _player.life / 5;
        uint heartId = _player.life % 5;

        Vec2f pos = Vec2f.zero;

        for (int i; i < maxHearts; ++i) {
            int id = 0;
            if (i < nbFullHearts) {
                id = 4;
            }
            else if (i == nbFullHearts) {
                id = heartId;
            }
            _sprites[id].draw(pos);

            pos.x += _sprites[id].width() + 16f;
        }
    }
}

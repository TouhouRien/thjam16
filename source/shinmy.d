module shinmy;

import atelier;
import material;
import hearts;

final class PlayerComponent : EntityComponent {
    private {
        int _life, _hearts;
    }

    @property {
        int life() const {
            return _life;
        }

        int hearts() const {
            return _hearts;
        }

        bool isDead() const {
            return _life <= 0;
        }
    }

    void setHearts(int hearts_) {
        _hearts = max(1, hearts_);
        _life = _hearts * 4;
    }

    void damage() {
        if (_life > 0)
            _life--;
    }

    override void setup() {
    }

    override void update() {
    }
}

final class PlayerController : Controller!Actor {
    override void onStart() {
        entity.addComponent!PlayerComponent();
        Atelier.ui.addUI(new HeartsUI(entity.getComponent!PlayerComponent()));
        setBehavior(new PlayerBehavior);
    }

    override void onTeleport(uint direction, bool isExit) {
        setBehavior(new DefaultTeleporterBehavior(direction, isExit));
    }
}

final class PlayerBehavior : Behavior!Actor {
    private {
        Vec3i _lastValidPosition = Vec3i.zero;
        Timer _hitTimer;
        Timer _deathTimer;
        Actor _needle;
        PlayerComponent _player;
        PlayerAnimator _animator;
    }

    override void onStart() {
        _player = entity.getComponent!PlayerComponent();
        _player.setHearts(4);

        _animator = PlayerAnimator(entity);
    }

    override void update() {
        _hitTimer.update();
        _deathTimer.update();
        _animator.update();

        Vec2f delta = (Atelier.world.getMousePosition() - entity.cameraPosition());
        entity.angle = delta.angle().radToDeg() + 90f;

        if (_animator.mustRespawn()) {
            entity.setVelocity(Vec3f.zero);
            entity.accelerate(Vec3f.zero);
            entity.setPosition(_lastValidPosition);
            _animator.respawn();
        }

        if (_animator.step == PlayerAnimator.Step.die && !_deathTimer.isRunning) {
            reloadScene();
        }

        if (_animator.step == PlayerAnimator.Step.grab) {
            if (!_needle) {
                _animator.respawn();
                entity.setGravity(0.8f);
            }
            else {
                if (_needle.sendEvent("isRecalled") == "done") {
                    _needle = null;

                    Sound sound = Atelier.res.get!Sound("needle_get");
                    Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.9f, 1.05f)));
                    entity.setGravity(0.8f);
                }
            }
        }

        if (_animator.canMove()) {
            // Record last valid ground grass tile
            int material = Atelier.world.scene.getMaterial(entity.getPosition());
            if (entity.isOnGround && material == Material.Grass) {
                _lastValidPosition = entity.getPosition();
            }

            Vec2f acceldir = Vec2f.zero;
            Vec2f movedir = Atelier.input.getActionVector("left", "right", "up", "down");

            if (movedir != Vec2f.zero) {
                _animator.walk();
                movedir.normalize();
                acceldir += movedir * 1f;
            }
            else {
                _animator.stop();
            }

            if (_needle) {
                if (_needle.sendEvent("isRecalled") == "done") {
                    _needle = null;

                    Sound sound = Atelier.res.get!Sound("needle_get");
                    Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.9f, 1.05f)));
                }
            }

            if (Atelier.input.isActionActivated("needleThrow")) {
                needleThrow();
            }

            if (Atelier.input.isActionActivated("needleSwing")) {
                needleSwing();
            }

            if (Atelier.input.isActionActivated("needlePlant")) {
                needlePlant();
            }

            entity.accelerate(Vec3f(acceldir, 0f));
        }

        // Respawn when hitting water
        int material = Atelier.world.scene.getMaterial(entity.getPosition());
        bool isEmptyTile = material == Material.Water;
        if (entity.isOnGround && isEmptyTile && _animator.canMove()) {
            if (_needle) {
                _needle.unregister();
                _needle = null;
            }
            _animator.fall();
            entity.setGravity(0.8f);
        }
    }

    override void onImpact(Entity target, Vec3f normal) {
        if (!_animator.canMove() || _hitTimer.isRunning) {
            return;
        }

        Sound sound = Atelier.res.get!Sound("player_hit");
        Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.95f, 1.05f)));
        _hitTimer.start(30);

        _player.damage();
        entity.setEffect(new FlashEffect(Color(1f, 0.8f, 0.8f), 1f, 15, 15, Spline.sineInOut));
        entity.setVelocity(normal * 3f);
        if (_player.isDead()) {
            _animator.die();
            _deathTimer.start(120);
        }
    }

    // Left click: swing needle
    void needleSwing() {
        if (!_needle) {
            Sound sound = Atelier.res.get!Sound("needle_swing");
            Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.9f, 1.05f)));

            _animator.swing();

            Proxy proxy = Atelier.res.get!Proxy("player_swing");
            proxy.angle = entity.angle + 90f;
            proxy.attachTo(entity);
            proxy.setController("swing");
            Atelier.world.addEntity(proxy);
        }
    }

    // Right click: throw needle
    void needleThrow() {
        if (!_needle) {
            Sound sound = Atelier.res.get!Sound("needle_throw");
            Atelier.audio.play(new SoundPlayer(sound));

            _needle = Atelier.res.get!Actor("needle");
            _needle.setPosition(entity.getPosition() + Vec3i(0, 0, 6));

            Vec2f delta = (Atelier.world.getMousePosition() - entity.cameraPosition());
            _needle.angle = delta.angle().radToDeg();
            Atelier.world.addEntity(_needle);
        }
        else {
            if ("grab" == _needle.sendEvent("recall")) {
                entity.setGravity(0f);
                _animator.grab();
            }
        }
    }

    // E: plant needle
    void needlePlant() {
        if (!_needle) {
            _needle = Atelier.res.get!Actor("needle");
            _needle.setName("needle.plant");
            _needle.setPosition(entity.getPosition());
            Atelier.world.addEntity(_needle);
            _needle.sendEvent("plant");

            _animator.plant();
        }
    }

    void reloadScene() {
        string scene = Atelier.env.getScene();
        Atelier.world.load(scene);
    }
}

// Une FSM pour mieux organiser les anims
struct PlayerAnimator {
    enum Step {
        init_,
        idle,
        walk,
        swing,
        plant,
        fall,
        grab,
        respawn,
        die
    }

    private {
        Step _step = Step.init_;
        Actor _actor;
        Sound[] _walkSounds;
        Timer _walkTimer, _respawnTimer;
    }

    @property {
        Step step() const {
            return _step;
        }
    }

    this(Actor actor) {
        _actor = actor;

        foreach (key; ["player_step1", "player_step2"]) {
            _walkSounds ~= Atelier.res.get!Sound(key);
        }
    }

    void stop() {
        final switch (_step) with (Step) {
        case respawn:
        case idle:
        case swing:
        case plant:
        case fall:
        case grab:
        case die:
            break;
        case init_:
        case walk:
            _actor.setGraphic("idle");
            _step = Step.idle;
            break;
        }
        _walkTimer.start(4);
    }

    void grab() {
        final switch (_step) with (Step) {
        case idle:
        case swing:
        case plant:
        case fall:
        case init_:
        case walk:
            _actor.setGraphic("idle");
            _step = Step.idle;
            break;
        case respawn:
        case grab:
        case die:
            break;
        }
        _walkTimer.start(4);
    }

    void walk() {
        final switch (_step) with (Step) {
        case init_:
        case idle:
            _actor.setGraphic("walk");
            _step = Step.walk;
            break;
        case swing:
        case plant:
        case fall:
            break;
        case walk:
            _walkTimer.update();
            if (!_walkTimer.isRunning) {
                _walkTimer.start(16);

                Atelier.audio.play(new SoundPlayer(_walkSounds[Atelier.rng.rand(0, 2)], Atelier.rng.rand(0.6f, 1.2f)));
            }
            break;
        case respawn:
        case grab:
        case die:
            break;
        }
    }

    void swing() {
        final switch (_step) with (Step) {
        case init_:
        case idle:
        case walk:
            _actor.setGraphic("swing");
            _step = Step.swing;
            break;
        case respawn:
        case swing:
        case plant:
        case fall:
        case grab:
        case die:
            break;
        }
    }

    void plant() {
        final switch (_step) with (Step) {
        case init_:
        case idle:
        case walk:
            _actor.setGraphic("plant");
            _step = Step.plant;
            break;
        case respawn:
        case swing:
        case plant:
        case fall:
        case grab:
        case die:
            break;
        }
    }

    void fall() {
        final switch (_step) with (Step) {
        case init_:
        case idle:
        case walk:
        case swing:
        case plant:
        case grab:
            _respawnTimer.start(48);
            _actor.setGraphic("fall");
            _step = Step.fall;

            Sound sound = Atelier.res.get!Sound("player_fall");
            Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.8f, 1.1f)));
            break;
        case respawn:
        case fall:
        case die:
            break;
        }
    }

    void respawn() {
        _actor.setGraphic("idle");
        _step = Step.idle;
    }

    void die() {
        _actor.setGraphic("die");
        _step = Step.die;
    }

    void update() {
        final switch (_step) with (Step) {
        case init_:
        case idle:
        case walk:
        case respawn:
        case grab:
            break;
        case swing:
        case plant:
            if (!isPlaying()) {
                _actor.setGraphic("idle");
                _step = Step.idle;
            }
            break;
        case fall:
            _respawnTimer.update();
            if (!isPlaying() && !_respawnTimer.isRunning) {
                _actor.setGraphic("idle");
                _step = Step.respawn;
            }
            break;
        case die:
            break;
        }
    }

    private bool isPlaying() {
        return _actor.getGraphic() && _actor.getGraphic().isPlaying();
    }

    bool canMove() {
        final switch (_step) with (Step) {
        case init_:
        case idle:
        case walk:
        case swing:
            return true;
        case fall:
        case plant:
        case respawn:
        case grab:
        case die:
            return false;
        }
    }

    bool mustRespawn() {
        final switch (_step) with (Step) {
        case init_:
        case idle:
        case walk:
        case swing:
        case plant:
        case fall:
        case grab:
        case die:
            return false;
        case respawn:
            return true;
        }
    }
}

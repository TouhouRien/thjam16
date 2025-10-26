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
        Actor _needleThrow;
        Actor _needlePlant;
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
        _animator.update();

        if (_animator.mustRespawn()) {
            entity.setVelocity(Vec3f.zero);
            entity.accelerate(Vec3f.zero);
            entity.setPosition(_lastValidPosition);
            _animator.respawn();
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
                entity.angle = radToDeg(movedir.angle()) + 90f;
                acceldir += movedir * 1f;
            }
            else {
                _animator.stop();
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
            _animator.fall();
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
            Atelier.log("GAME OVER");
        }
    }

    // Left click: swing needle
    void needleSwing() {
        if (!_needleThrow && !_needlePlant) {
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
        if (!_needleThrow && !_needlePlant) {
            Sound sound = Atelier.res.get!Sound("needle_throw");
            Atelier.audio.play(new SoundPlayer(sound));

            _needleThrow = Atelier.res.get!Actor("needle");
            _needleThrow.setPosition(entity.getPosition() + Vec3i(0, 0, 6));
            _needleThrow.angle = entity.angle - 90f;
            Atelier.world.addEntity(_needleThrow);
        }
        else if (_needleThrow) {
            // @TODO delayer
            _needleThrow.unregister();
            _needleThrow = null;
        }
        else if (_needlePlant) {
            // @TODO delayer
            _needlePlant.unregister();
            _needlePlant = null;
        }
    }

    // E: plant needle
    void needlePlant() {
        // @TODO ajouter Behavior pour needle plant
        if (!_needleThrow && !_needlePlant) {
            Sound sound = Atelier.res.get!Sound("needle_plant");
            Atelier.audio.play(new SoundPlayer(sound));

            _needlePlant = Atelier.res.get!Actor("needle.plant");
            _needlePlant.setName("needle.plant"); // ne devrait pas etre necessaire Enalye :(
            _needlePlant.setPosition(entity.getPosition());
            _needlePlant.angle = 0f;
            Atelier.world.addEntity(_needlePlant);
            _animator.plant();
        }
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
        respawn
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
            break;
        case init_:
        case walk:
            _actor.setGraphic("idle");
            _step = Step.idle;
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
            _respawnTimer.start(48);
            _actor.setGraphic("fall");
            _step = Step.fall;

            Sound sound = Atelier.res.get!Sound("player_fall");
            Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.8f, 1.1f)));
            break;
        case respawn:
        case fall:
            break;
        }
    }

    void respawn() {
        _actor.setGraphic("idle");
        _step = Step.idle;
    }

    void update() {
        final switch (_step) with (Step) {
        case init_:
        case idle:
        case walk:
        case respawn:
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
            return false;
        case respawn:
            return true;
        }
    }
}

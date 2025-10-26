module enemy;

import atelier;

final class EnemyController : Controller!Actor {
    private {
        string _enemyId;
    }

    this(string enemyId) {
        _enemyId = enemyId;
    }

    override void onStart() {
        setBehavior(new EnemyBehavior(_enemyId));
    }
}

final class EnemyBehavior : Behavior!Actor {
    private {
        bool _shot = false;
        bool _dead = false;

        int _life;
        string _enemyId;
        GrTask _task;
        Timer _deathTimer;
    }

    this(string enemyId, int life = 5) {
        _enemyId = enemyId;
        _life = life;
    }

    override void onStart() {
        entity.setShadow(true); // @TODO expose
        //entity.setFrictionBrake(0f); // @TODO expose
        //entity.isHovering(true); // @TODO expose
        _task = Atelier.script.callEvent(_enemyId ~ "Behavior", [
                grGetNativeType("Actor")
            ], [GrValue(entity)]);
    }

    override void onImpact(Entity target, Vec3f normal) {
        if(entity.isEnabled()) {
            _life--;
            if (_life > 0) {
                Sound sound = Atelier.res.get!Sound("enemy_hit");
                Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.8f, 1.1f)));
                entity.setVelocity(normal * 3f);
            }

            entity.setEffect(new FlashEffect(Color.red, 1f, 10, 10, Spline.sineInOut));
        }
    }

    override void update() {
        _deathTimer.update();

        if(entity.isEnabled && !_dead) {
            if (_life == 0) {
                Sound sound = Atelier.res.get!Sound("enemy_death");
                Atelier.audio.play(new SoundPlayer(sound));
                _deathTimer.start(40);
                _task.kill();
                _dead = true;

                // @Enalye animation de mort ici
                entity.setGraphic("death");
            }
        }

        if (_dead && !_deathTimer.isRunning) {
            entity.setEnabled(false);
            entity.unregister();
        }
    }
}

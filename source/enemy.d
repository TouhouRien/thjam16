module enemy;

import atelier;
import victory;

final class EnemyController : Controller!Actor {
    private {
        string _enemyId;
        int _startLife;
    }

    this(string enemyId, int startLife = 5) {
        _enemyId = enemyId;
        _startLife = startLife;
    }

    override void onStart() {
        setBehavior(new EnemyBehavior(_enemyId, _startLife));
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
        Proxy _proxy;
    }

    this(string enemyId, int life) {
        _enemyId = enemyId;
        _life = life;
    }

    override void onStart() {
        //entity.setShadow(true);
        _task = Atelier.script.callEvent(_enemyId ~ "Behavior", [
                grGetNativeType("Actor")
            ], [GrValue(entity)]);
        setProxy("enemy_hitbox");
    }

    override void onImpact(Entity target, Vec3f normal) {
        if (entity.isEnabled()) {
            int dmg = 1;
            if (target.getName == "explosion_hitbox") {
                dmg = 4;
            }

            _life -= dmg;
            _life = max(0, _life);

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

        // Kill enemy on fall
        if (entity.getLevel == 0) {
            _life = 0;
        }

        if (entity.isEnabled && !_dead) {
            if (_life <= 0) {
                Sound sound = Atelier.res.get!Sound("enemy_death");
                Atelier.audio.play(new SoundPlayer(sound));
                //entity.setShadow(false);
                entity.setSpeed(0f, 0f);

                if (_task) {
                    _task.kill();
                    _task = null;
                }

                _deathTimer.start(40);
                _dead = true;

                entity.setGraphic("death");
                entity.setLayer(Entity.Layer.above);
            }
        }

        if (_dead && !_deathTimer.isRunning) {
            entity.setEnabled(false);
            entity.unregister();

            if (_proxy) {
                _proxy.unregister();
                _proxy = null;
            }

            if (entity.getName == "yamame") {
                Atelier.ui.clearUI();
                Atelier.world.close();
                Atelier.ui.addUI(new Victory);
            }
        }
    }

    override void onClose() {
        if (_proxy) {
            _proxy.unregister();
            _proxy = null;
        }
        if (_task) {
            _task.kill();
            _task = null;
        }
    }

    void setProxy(string proxyName) {
        _proxy = Atelier.res.get!Proxy(proxyName);
        _proxy.setName(proxyName);
        _proxy.attachTo(entity);
        //_proxy.getHurtbox().isInvincible = true;
        Atelier.world.addEntity(_proxy);
    }
}

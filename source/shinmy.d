module shinmy;

import atelier;
import material;

final class PlayerController : Controller!Actor {
    override void onStart() {
        setBehavior(new PlayerBehavior);
    }

    override void onTeleport(uint direction, bool isExit) {
        setBehavior(new DefaultTeleporterBehavior(direction, isExit));
    }
}

final class PlayerBehavior : Behavior!Actor {
    Vec3i _lastValidPosition = Vec3i.zero;
    Timer _stateTimer;
    Actor _needle;
    bool _needleThrown;

    override void update() {
        _stateTimer.update();

        // Record last valid ground tile
        if (entity.isOnGround && entity.getBaseMaterial() == Material.Grass) {
            _lastValidPosition = entity.getPosition();
        }

        // Respawn when hitting water
        if (entity.getLevel() < 0) {
            entity.setGraphic("fall");
            _stateTimer.start(40);
        }

        if (!entity.getGraphic().isPlaying) {
            entity.setPosition(_lastValidPosition);
            entity.setGraphic("idle");
        }

        if (!_stateTimer.isRunning) {
            Vec2f acceldir = Vec2f.zero;
            Vec2f movedir = Atelier.input.getActionVector("left", "right", "up", "down");

            if (movedir != Vec2f.zero) {
                movedir.normalize();
                entity.angle = radToDeg(movedir.angle()) + 90f;
                acceldir += movedir * 1f;
            }

            if (Atelier.input.isActionActivated("needleThrow")) {
                needleThrow();
            }

            if (Atelier.input.isActionActivated("needleSwing")) {
                needleSwing();
            }

            entity.accelerate(Vec3f(acceldir, 0f));
        }
    }

    override void onImpact(Entity target, Vec3f normal) {
        /*if (target.hasTag("shot")) {
            Atelier.log("Got hit by shot");
        }*/
        //Atelier.log("Got hit");
    }

    // Left click: swing needle
    void needleSwing() {
        if (!_needleThrown) {
            entity.setGraphic("swing");
        }
        // check collisions against enemies
        //Entity[] enemies = Atelier.world.findByTag("enemy");
    }

    // Right click: throw needle
    void needleThrow() {
        // check collisions against pins, walls
        //Entity[] enemies = Atelier.world.findByTag("pin");

        // À faire: vérifier si on a l’aiguille sur nous
        if (!_needleThrown) {
            _needle = Atelier.res.get!Actor("needle");
            _needle.setPosition(entity.getPosition() + Vec3i(0, 0, 6));
            _needle.angle = entity.angle - 90f;
            Atelier.world.addEntity(_needle);
            _needleThrown = true;
        } else {
            _needle.unregister();
            _needleThrown = false;
        }
    }

    // Space? Right click on ground?
    void needlePlant() {
        // check collisions against buttons
        //Entity[] enemies = Atelier.world.findByTag("button");
    }
}

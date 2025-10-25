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
    Timer _respawnTimer;
    Actor _needleThrow;
    Actor _needlePlant;
    bool _invulnerable;
    uint _health = 12; // 3 coeurs

    override void update() {
        _respawnTimer.update();

        // Record last valid ground tile
        if (entity.isOnGround && entity.getBaseMaterial() == Material.Grass) {
            _lastValidPosition = entity.getPosition();
        }

        // Respawn when hitting water
        if (entity.getLevel() < 0) {
            entity.setGraphic("fall");
            _respawnTimer.start(40);
            _invulnerable = true;
        }

        if (!entity.getGraphic().isPlaying) {
            entity.setPosition(_lastValidPosition);
            entity.setGraphic("idle");
        }

        if (!_respawnTimer.isRunning) {
            _invulnerable = false;
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

            if (Atelier.input.isActionActivated("needlePlant")) {
                needlePlant();
            }

            entity.accelerate(Vec3f(acceldir, 0f));
        }
    }

    override void onImpact(Entity target, Vec3f normal) {
        if (_invulnerable) {
            return;
        }

        _health--;
        if (_health == 0) {
            Atelier.log("GAME OVER");
        }
    }

    // Left click: swing needle
    void needleSwing() {
        if (!_needleThrow && !_needlePlant) {
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
        if (!_needleThrow && !_needlePlant) {
            _needleThrow = Atelier.res.get!Actor("needle");
            _needleThrow.setPosition(entity.getPosition() + Vec3i(0, 0, 6));
            _needleThrow.angle = entity.angle - 90f;
            Atelier.world.addEntity(_needleThrow);
        } else if (_needleThrow) {
            // @TODO delayer
            _needleThrow.unregister();
            _needleThrow = null;
        } else if (_needlePlant) {
            // @TODO delayer
            _needlePlant.unregister();
            _needlePlant = null;
        }
    }

    // E: plant needle
    void needlePlant() {
        // @TODO ajouter Behavior pour needle plant
        if (!_needleThrow && !_needlePlant) {
            _needlePlant = Atelier.res.get!Actor("needle.plant");
            _needlePlant.setName("needle.plant"); // ne devrait pas etre necessaire Enalye :(
            _needlePlant.setPosition(entity.getPosition());
            _needlePlant.angle = 0f;
            Atelier.world.addEntity(_needlePlant);
            //entity.setGraphic("plant");
        }

        // check collisions against buttons
        //Entity[] enemies = Atelier.world.findByTag("button");
    }
}

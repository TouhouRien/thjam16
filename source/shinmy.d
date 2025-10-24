module shinmy;

import atelier;
import material;

final class PlayerController : Controller!Actor {
    private {
        Vec3i _lastValidPosition = Vec3i.zero;
    }

    override void onStart() {
        setBehavior(new PlayerBehavior);
    }

    override void onUpdate() {
        // Record last valid ground tile
        if (entity.getLevel() == 1 && entity.isOnGround && entity.getBaseMaterial() == Material.Grass) {
            _lastValidPosition = entity.getPosition();
        }

        // Respawn when hitting water
        if (entity.getLevel() == 0 && entity.isOnGround) {
            entity.setPosition(_lastValidPosition);
        }
    }

    override void onTeleport(uint direction, bool isExit) {
        setBehavior(new DefaultTeleporterBehavior(direction, isExit));
    }
}

final class PlayerBehavior : Behavior!Actor {
    override void update() {
        Vec2f acceldir = Vec2f.zero;
        Vec2f movedir = Atelier.input.getActionVector("left", "right", "up", "down");

        if (movedir != Vec2f.zero) {
            movedir.normalize();
            entity.angle = radToDeg(movedir.angle()) + 90f;
            acceldir += movedir * 1f;
        }

        entity.accelerate(Vec3f(acceldir, 0f));
    }

    // Left click: swing needle
    void needleSwing() {
        // check collisions against enemies
        //Entity[] enemies = Atelier.world.findByTag("enemy");
    }

    // Right click: throw needle
    void needleThrow() {
        // check collisions against pins, walls
        //Entity[] enemies = Atelier.world.findByTag("pin");
    }

    // Space? Right click on ground?
    void needlePlant() {
        // check collisions against buttons
        //Entity[] enemies = Atelier.world.findByTag("button");
    }
}
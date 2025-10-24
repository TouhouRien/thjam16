module suwako;

import atelier;
import std.stdio;

final class SuwakoController : Controller!Actor {
    override void onStart() {
        setBehavior(new SuwakoBehavior);
    }
}

final class SuwakoBehavior : Behavior!Actor {
    override void update() {
        Vec2f acceldir = Vec2f.zero;
        Vec3i playerPos = Atelier.world.player.getPosition();
        Vec3i distToPlayer = playerPos - entity.getPosition();

        // if distance less than 80 pixels
        if (distToPlayer.lengthSquared < 80 * 80) {
            // move towards player at 75% of their speed
            Vec2f movedir = Vec2f(distToPlayer.x, distToPlayer.y).normalized;
            entity.angle = radToDeg(movedir.angle()) + 90f;
            acceldir += movedir * 0.75f;

            // fire!
        }

        entity.accelerate(Vec3f(acceldir, 0f));
    }
}
module suwako;

import atelier;
import std.stdio;

final class SuwakoController : Controller!Actor {
    override void onStart() {
        setBehavior(new SuwakoBehavior);
    }
}

final class SuwakoBehavior : Behavior!Actor {
    bool _shot = false;

    override void update() {
        Vec2f acceldir = Vec2f.zero;
        Vec3i playerPos = Atelier.world.player.getPosition();
        Vec3i suwakoPos = entity.getPosition();
        Vec3i distToPlayer = playerPos - suwakoPos;

        // if distance less than 80 pixels
        if (distToPlayer.lengthSquared < 80 * 80) {
            // move towards player at 75% of their speed
            Vec2f moveDir = Vec2f(distToPlayer.x, distToPlayer.y).normalized;
            float moveAng = radToDeg(moveDir.angle()) + 90f;

            entity.angle = radToDeg(moveDir.angle()) + 90f;
            acceldir += moveDir * 0.75f;

            // fire!
            /*if (!_shot) {
                Shot shot = Atelier.res.get!Shot("bullet");
                if (shot) {
                    shot.setPosition(suwakoPos);
                    shot.setSpeed(2f, 0f);
                    shot.angle(moveAng);
                    Atelier.world.addEntity(shot);
                }

                writeln("FIRE AT THEM");

                _shot = true;
            }*/
        }

        entity.accelerate(Vec3f(acceldir, 0f));
    }
}
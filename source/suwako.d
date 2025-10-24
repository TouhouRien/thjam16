module suwako;

import atelier;

final class SuwakoController : Controller!Actor {
    override void onStart() {
        setBehavior(new SuwakoBehavior());
    }
}

final class SuwakoBehavior : Behavior!Actor {
    bool _shot = false;
    GrTask _task;

    override void onStart() {
        _task = Atelier.script.callEvent("suwakoBehavior", [grGetNativeType("Entity")], [GrValue(entity)]);
    }

    override void onImpact(Entity target, Vec3f normal) {
        // Suwako getting hit
    }

    override void update() {
        Vec2f acceldir = Vec2f.zero;

        Actor player = Atelier.world.player;
        Vec3i playerPos = player.getPosition();
        Vec3i suwakoPos = entity.getPosition();
        Vec3i distToPlayer = playerPos - suwakoPos;

        // if distance less than 80 pixels and player is on ground
        if (distToPlayer.lengthSquared < 80 * 80 && player.isOnGround) {
            // move towards player at 75% of their speed
            Vec2f moveDir = Vec2f(distToPlayer.x, distToPlayer.y).normalized;
            float moveAng = radToDeg(moveDir.angle()) + 90f;

            entity.angle = radToDeg(moveDir.angle()) + 90f;
            acceldir += moveDir * 0.75f;
        }

        entity.accelerate(Vec3f(acceldir, 0f));
    }
}
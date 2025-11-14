module button;

import atelier;
import needle;

final class ButtonController : Controller!Prop {
    override void onStart() {
        setBehavior(new ButtonBehavior);
    }
}

final class ButtonBehavior : Behavior!Prop {
    private bool _active = false;

    override void update() {
        if (!entity.isEnabled())
            return;

        int radiusSquared = 16 * 16;
        Vec3i entityPos = entity.getPosition();

        bool isNeedleOnButton = false;

        Actor needle = cast(Actor)Atelier.world.find("needle");

        if (needle) {
            NeedleThrowController controller = cast(NeedleThrowController)needle.getController();

            if (controller && controller.isPlanted) {
                Vec3i needlePos = needle.getPosition();
                Vec3i distToNeedle = needlePos - entityPos;
                isNeedleOnButton = distToNeedle.lengthSquared < radiusSquared;
            }
        }

        Vec3i playerPos = Atelier.world.player.getPosition();
        Vec3i distToPlayer = playerPos - entityPos;

        bool isPlayerOnButton = distToPlayer.lengthSquared < radiusSquared;

        // if distance less than 16 pixels
        if (isPlayerOnButton || isNeedleOnButton) {
            activate();
        }
        else {
            deactivate();
        }
    }

    private void activate() {
        if (!_active) {
            Sound sound = Atelier.res.get!Sound("button_click");
            Atelier.audio.play(new SoundPlayer(sound));
            entity.setGraphic("actif");
            Atelier.script.callEvent("button_activate_" ~ entity.getName, [
                    grGetNativeType("Entity")
                ], [GrValue(entity)]);
            _active = true;
        }
    }

    private void deactivate() {
        if (_active) {
            Sound sound = Atelier.res.get!Sound("button_unclick");
            Atelier.audio.play(new SoundPlayer(sound));
            Atelier.script.callEvent("button_deactivate_" ~ entity.getName, [
                    grGetNativeType("Entity")
                ], [GrValue(entity)]);
            entity.setGraphic("inactif");
            _active = false;
        }
    }
}

final class ToggleController : Controller!Prop {
    override void onStart() {
        setBehavior(new ToggleBehavior);
    }
}

final class ToggleBehavior : Behavior!Prop {
    private bool _active = false;

    override void update() {
        if (!entity.isEnabled())
            return;
        int radiusSquared = 16 * 16;
        Vec3i entityPos = entity.getPosition();

        bool isNeedleOnButton = false;

        Entity needlePlant = Atelier.world.find("needle.plant");
        if (needlePlant) {
            Vec3i needlePos = needlePlant.getPosition();
            Vec3i distToNeedle = needlePos - entityPos;
            isNeedleOnButton = distToNeedle.lengthSquared < radiusSquared;
        }

        Vec3i playerPos = Atelier.world.player.getPosition();
        Vec3i distToPlayer = playerPos - entityPos;

        bool isPlayerOnButton = distToPlayer.lengthSquared < radiusSquared;

        // if distance less than 16 pixels
        if (isPlayerOnButton || isNeedleOnButton) {
            activate();
        }
    }

    private void activate() {
        if (!_active) {
            Sound sound = Atelier.res.get!Sound("button_click");
            Atelier.audio.play(new SoundPlayer(sound));
            entity.setGraphic("actif");
            Atelier.script.callEvent("button_activate_" ~ entity.getName, [
                    grGetNativeType("Entity")
                ], [GrValue(entity)]);
            _active = true;
        }
    }
}

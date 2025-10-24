module button;

import atelier;

final class ButtonController : Controller!Prop {
    override void onStart() {
        setBehavior(new ButtonBehavior);
    }
}

final class ButtonBehavior : Behavior!Prop {
    private bool _active = false;

    override void update() {
        Vec3i playerPos = Atelier.world.player.getPosition();
        Vec3i distToPlayer = playerPos - entity.getPosition();

        // if distance less than 16 pixels
        if (distToPlayer.lengthSquared < 16 * 16) {
            activate();
        } else {
            deactivate();
        }
    }

    private void activate() {
        if (!_active) {
            Sound sound = Atelier.res.get!Sound("button_click");
            Atelier.audio.play(new SoundPlayer(sound));
            entity.setGraphic("actif");
            Atelier.script.callEvent("button_activate_" ~ entity.getName, [grGetNativeType("Entity")], [GrValue(entity)]);
            _active = true;
        }
    }

    private void deactivate() {
        if (_active) {
            //Sound sound = Atelier.res.get!Sound("button_unclick");
            //Atelier.audio.play(new SoundPlayer(sound));
            Atelier.script.callEvent("button_deactivate_" ~ entity.getName, [grGetNativeType("Entity")], [GrValue(entity)]);
            entity.setGraphic("inactif");
            _active = false;
        }
    }
}


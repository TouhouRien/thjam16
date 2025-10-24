module button;

import atelier;

final class ButtonController : Controller!Prop {
    override void onStart() {
        setBehavior(new ButtonBehavior);
    }
}

final class ButtonBehavior : Behavior!Prop {
    private bool _active;

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
        // play sfx
        entity.setGraphic("actif");
        _active = true;
    }

    private void deactivate() {
        // reverse sfx?
        entity.setGraphic("inactif");
        _active = false;
    }
}


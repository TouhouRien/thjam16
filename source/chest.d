module chest;

import atelier;
import shinmy;

final class ChestController : Controller!Actor {
    override void onStart() {
        entity.setGravity(0f);
        setBehavior(new ChestBehavior());
    }
}

final class ChestBehavior : Behavior!Actor {
    private {
        bool _open = false;
    }

    override void onImpact(Entity target, Vec3f normal) {
        if (_open || target.hasTag("needle")) {
            return;
        }

        _open = true;
        entity.setGraphic("open");
        entity.addTag("open");

        Sound sound = Atelier.res.get!Sound("door_open");
        Atelier.audio.play(new SoundPlayer(sound));

        if (entity.hasTag("caelid")) {
            Atelier.world.transitionScene("levelx1", "caelid", 0);
        } else {
            Actor player = Atelier.world.player;
            player.setGraphic("collect");

            PlayerComponent playerComponent = player.getComponent!PlayerComponent();
            playerComponent.healthUp();
        }
    }

    override void update() {
    }
}
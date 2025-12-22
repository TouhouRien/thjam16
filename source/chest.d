module chest;

import atelier;

final class ChestController : Controller!Actor {
    override void onStart() {
        entity.setGravity(0f);
        setBehavior(new ChestBehavior());
    }
}

final class ChestBehavior : Behavior!Actor {
    private {
        bool isOpen = false;
    }

    override void onImpact(Entity target, Vec3f normal) {
        if (isOpen || target.hasTag("needle")) {
            return;
        }

        entity.setGraphic("open");

        if (entity.hasTag("caelid")) {
            Atelier.log("go to caelid");
        } else {
            Atelier.log("life up");
        }
    }

    override void update() {
    }
}
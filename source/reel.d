module reel;

import atelier;

final class ReelController : Controller!Prop {
    override void onStart() {
        setBehavior(new ReelBehavior);
    }
}

final class ReelBehavior : Behavior!Prop {
    override void update() {
    }
}
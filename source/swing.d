module swing;

import atelier;

final class SwingController : Controller!Proxy {
    override void onStart() {
        setBehavior(new SwingBehavior);
    }
}

final class SwingBehavior : Behavior!Proxy {
    private {
        Timer _timer;
    }

    override void onStart() {
        _timer.start(8);
    }

    override void update() {
        _timer.update();

        if (!_timer.isRunning) {
            entity.unregister();
            return;
        }
    }

    override void onImpact(Entity target, Vec3f normal) {
    }
}

module mushroom;

import atelier;

final class MushroomController : Controller!Prop {
    override void onStart() {
        setBehavior(new MushroomBehavior());
    }
}

final class MushroomBehavior : Behavior!Prop {
    private {
        Timer _deathTimer;
        Proxy _proxy;
        bool _dead = false;
    }

    override void onStart() {
        entity.setShadow(false);
    }

    override void onImpact(Entity target, Vec3f normal) {
        Sound sound = Atelier.res.get!Sound("sexplode");
        Atelier.audio.play(new SoundPlayer(sound));

        _deathTimer.start(40);
        _dead = true;

        entity.setGraphic("explode");
        entity.setLayer(Entity.Layer.above);

        EntityGraphic graphic = entity.getGraphic();
        graphic.setScale(Vec2f.half);
        Atelier.script.callEvent("mushroomSplode", [
            grGetNativeType("Actor")
        ], [GrValue(entity)]);

        setProxy("explosion_hitbox");
    }

    void setProxy(string proxyName) {
        _proxy = Atelier.res.get!Proxy(proxyName);
        _proxy.setName(proxyName);
        _proxy.attachTo(entity);
        _proxy.getHurtbox().isInvincible = true;
        Atelier.world.addEntity(_proxy);
    }

    override void update() {
        _deathTimer.update();

        if (_dead && !_deathTimer.isRunning) {
            entity.setEnabled(false);
            entity.unregister();

            if (_proxy) {
                _proxy.unregister();
                _proxy = null;
            }
        }
    }
}
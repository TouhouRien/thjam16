module needle;

import atelier;

const float minThreadLength = 150f;
const float maxThreadLength = 250f;

final class NeedleThrowController : Controller!Actor {
    private {
        NeedleThrowBehavior _needleThrowBehavior;
        NeedleHookBehavior _needleHookBehavior;
        NeedleGrabBehavior _needleGrabBehavior;
    }

    @property {
        bool isPlanted() {
            return _needleThrowBehavior && _needleThrowBehavior.isPlanted();
        }

        Entity target() {
            return _needleThrowBehavior.target;
        }
    }

    override void onStart() {
        entity.setName("needle");
        _needleThrowBehavior = new NeedleThrowBehavior;
        setBehavior(_needleThrowBehavior);
    }

    override string onEvent(string event) {
        if (event == "plant" && !isPlanted) {
            sendEvent(event);
        }
        else if (event == "recall" && isPlanted) {
            _needleThrowBehavior.unplant();

            if (_needleThrowBehavior.targetsHeavy()) {
                _needleGrabBehavior = new NeedleGrabBehavior(_needleThrowBehavior);
                setBehavior(_needleGrabBehavior);
                _needleThrowBehavior = null;

                Sound sound = Atelier.res.get!Sound("needle_grab");
                Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.9f, 1.05f)));

                return "grab";
            }
            else {
                _needleHookBehavior = new NeedleHookBehavior(_needleThrowBehavior);
                setBehavior(_needleHookBehavior);
                _needleThrowBehavior = null;

                Sound sound = Atelier.res.get!Sound("needle_unplant");
                Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.9f, 1.05f)));
                return "hook";
            }
        }
        else if (event == "isRecalled" && _needleHookBehavior) {
            return sendEvent(event);
        }
        else if (event == "isRecalled" && _needleGrabBehavior) {
            return sendEvent(event);
        }

        return "";
    }
}

final class NeedleThrowBehavior : Behavior!Actor {
    private {
        Timer _timer;
        Vec3i _startPoint;
        uint _nodeCount;
        EntityThreadRenderer _renderer;
        bool _isPlanted;
        Entity _target;
        bool _targetsHeavy;
    }

    @property {
        bool isPlanted() {
            return _isPlanted;
        }

        bool targetsHeavy() {
            return _targetsHeavy;
        }

        Entity target() {
            return _target;
        }
    }

    override string onEvent(string event) {
        switch (event) {
        case "plant":
            if (entity.isRegistered() && !_isPlanted) {
                plant();
            }
            return "";
        default:
            return "";
        }
    }

    override void onStart() {
        if (!_isPlanted) {
            entity.setSpeed(5f, 0f);
            entity.setGravity(0f);
        }

        entity.setLayer(Entity.Layer.above);
        entity.setFrictionBrake(0f);
        entity.setCulling(false);

        _startPoint = entity.getPosition();

        _renderer = new EntityThreadRenderer(Atelier.world.player, entity);
        entity.addAuxGraphic("thread", _renderer);
        foreach (key, graphic; entity.getGraphics()) {
            graphic.addAuxGraphic("thread");
        }
        entity.setGraphic("throw", true);

        _timer.start(10);

        // spawn one node every 10 frames until we get 10 nodes
        while (_nodeCount < 10) {
            //_timer.start(1);

            Actor node = Atelier.res.get!Actor("thread.node");
            node.setPosition(entity.getPosition());
            node.angle = node.angle;
            _renderer.addNode(node);

            _nodeCount++;
        }
    }

    override void update() {
        if (_isPlanted) {
            entity.removeCollider();

            if (_target) {
                entity.setPosition(_target.getPosition());
            }

            return;
        }

        _timer.update();

        // plant needle if max thread length reached
        Vec3i delta = Atelier.world.player.getPosition() - entity.getPosition();
        if (delta.length >= minThreadLength) {
            plant();
        }
    }

    override void onHit(Entity target, Vec3f normal) {
        if (_isPlanted)
            return;

        _target = target;

        if (_target) {
            _targetsHeavy = _target.hasTag("reel");
        }

        plant();
    }

    override void onImpact(Entity target, Vec3f normal) {
        if (_isPlanted)
            return;

        _target = target;
        
        if (_target.hasTag("chest") && !_target.hasTag("open")) {
            _targetsHeavy = true;
        }

        plant();
    }

    void plant() {
        if (!_isPlanted) {
            entity.accelerate(Vec3f.zero);
            entity.setSpeed(0f, 0f);
            entity.setGravity(0.8f);
            entity.setGraphic("planted");
            _isPlanted = true;

            Sound sound = Atelier.res.get!Sound("needle_plant");
            Atelier.audio.play(new SoundPlayer(sound, Atelier.rng.rand(0.9f, 1.05f)));
        }
    }

    void unplant() {
        _isPlanted = false;
    }
}

final class NeedleHookBehavior : Behavior!Actor {
    private {
        Timer _timer;
        Vec3i _startPoint;
        uint _nodeCount;
        EntityThreadRenderer _renderer;
        Entity _target;
    }

    this(NeedleThrowBehavior throwBehavior) {
        _renderer = throwBehavior._renderer;
        _nodeCount = throwBehavior._nodeCount;
        _target = throwBehavior._target;
    }

    override string onEvent(string event) {
        switch (event) {
        case "isRecalled":
            return entity.isRegistered() ? "" : "done";
        default:
            return "";
        }
    }

    override void onStart() {
        Vec3i delta = Atelier.world.player.getPosition() - entity.getPosition();
        Vec3f dir = (cast(Vec3f)(delta)).normalized();
        entity.setVelocity(dir * 3f);

        entity.setGravity(0f);
        entity.setFrictionBrake(0f);
        entity.setLayer(Entity.Layer.above);
        entity.setGraphic("throw");

        _startPoint = entity.getPosition();

        _timer.start(10);
    }

    override void update() {
        Vec3i delta = Atelier.world.player.getPosition() - entity.getPosition();
        Vec3f dir = (cast(Vec3f)(delta)).normalized();
        entity.setVelocity(dir * 3f);

        if (_target && _target.type == Entity.Type.actor) {
            Vec3f move = cast(Vec3f)(entity.getPosition - _target.getPosition);
            _target.move(dir * 3f);
        }

        if (Atelier.world.player.getPosition().distanceSquared(entity.getPosition()) < (25 * 25)) {
            entity.unregister();
        }

        _timer.update();

        if (!_timer.isRunning() && _nodeCount >= 0) {
            _timer.start(10);
            _renderer.removeNode();
            _nodeCount--;
        }
    }
}

final class NeedleGrabBehavior : Behavior!Actor {
    private {
        Timer _timer;
        Vec3i _startPoint;
        uint _nodeCount;
        EntityThreadRenderer _renderer;
        Timer _timeout;
    }

    this(NeedleThrowBehavior throwBehavior) {
        _renderer = throwBehavior._renderer;
        _nodeCount = throwBehavior._nodeCount;
    }

    override string onEvent(string event) {
        switch (event) {
        case "isRecalled":
            return entity.isRegistered() ? "" : "done";
        default:
            return "";
        }
    }

    override void onStart() {
        entity.setGravity(0f);
        entity.setFrictionBrake(0f);
        entity.setLayer(Entity.Layer.above);
        entity.setGraphic("throw");

        _startPoint = entity.getPosition();

        _timer.start(10);
        _timeout.start(60);
    }

    override void update() {
        if (!_timeout.isRunning) {
            entity.unregister();
        }

        Vec3i delta = entity.getPosition() - Atelier.world.player.getPosition();
        Vec3f dir = (cast(Vec3f)(delta)).normalized();
        Atelier.world.player.setVelocity(dir * 5f);

        if (Atelier.world.player.getPosition().distanceSquared(entity.getPosition()) < (25 * 25)) {
            entity.unregister();
        }

        _timer.update();
        _timeout.update();

        if (!_timer.isRunning() && _nodeCount >= 0) {
            _timer.start(10);
            _renderer.removeNode();
            _nodeCount--;
        }
    }
}

final class EntityThreadRenderer : EntityGraphic {
    private {
        Entity _player, _needle;
        Actor[] _nodes;
        Color[12] _colors;
    }

    this(Entity a, Entity b) {
        _player = a;
        _needle = b;

        for (int i; i < _colors.length; ++i) {
            _colors[i] = Color.white.lerp(Color.red, easeInOutSine(i / cast(float) _colors.length));
        }
    }

    this(EntityThreadRenderer other) {

    }

    void addNode(Actor node) {
        _nodes ~= node;
    }

    void removeNode() {
        if (_nodes.length)
            _nodes.length--;
    }

    Vec3f _getNodeAccel(Vec3i node, Vec3i tensorA, Vec3i tensorB) {
        Vec3f accel = Vec3f.zero;
        Vec3i targetPos = (tensorA + tensorB) / 2;

        float dist = (tensorA - tensorB).length;
        float minDist = minThreadLength / 12f;
        float maxDist = maxThreadLength / 12f;
        float t = rlerp(minDist, maxDist, clamp(dist, minDist, maxDist));
        float tension = lerp(0f, 1.1f, easeInOutSine(t));

        accel += (cast(Vec3f)(targetPos - node)) * tension;

        return accel;
    }

    Color _getThreadColor(Vec2f start, Vec2f end) {
        float dist = start.distance(end);
        float minDist = minThreadLength / 12f;
        float maxDist = maxThreadLength / 12f;
        float t = rlerp(minDist, maxDist, clamp(dist, minDist, maxDist));
        return Color.red.lerp(Color.white, easeInOutSine(t));
    }

    override void update() {
        Vec3f[] localAccels, globalAccels;
        if (_nodes.length == 1) {
            localAccels ~= _getNodeAccel(_nodes[0].getPosition(), _player.getPosition(), _needle.getPosition());
        }
        else {
            foreach (int i; 0 .. cast(int) _nodes.length) {
                Vec3f accel = Vec3f.zero;

                if (i == 0) {
                    accel += _getNodeAccel(_nodes[0].getPosition(), _player.getPosition(), _nodes[1].getPosition());
                }
                else if (i + 1 == _nodes.length) {
                    accel += _getNodeAccel(_nodes[$ - 1].getPosition(), _nodes[$ - 2].getPosition(), _needle
                            .getPosition());
                }
                else {
                    accel += _getNodeAccel(_nodes[i].getPosition(), _nodes[i - 1].getPosition(), _nodes[i + 1]
                            .getPosition());
                }

                localAccels ~= accel;
            }
        }
        globalAccels.length = localAccels.length;

        //_nodes[i].move(accel);
        for (int i; i < _nodes.length; ++i) {
            globalAccels[i] = localAccels[i];
            if (i > 0) {
                globalAccels[i] += localAccels[i - 1] * 0.5f;
                if (i > 1) {
                    globalAccels[i] += localAccels[i - 2] * 0.25f;
                }
            }
            if ((i + 1) < _nodes.length) {
                globalAccels[i] += localAccels[i + 1] * 0.5f;
                if ((i + 2) < _nodes.length) {
                    globalAccels[i] += localAccels[i + 2] * 0.25f;
                }
            }
            _nodes[i].move(globalAccels[i]);
        }
    }

    override void draw(Vec2f offset, float alpha = 1f) {
        offset -= _needle.cameraPosition();

        Vec2f startPos = offset + _player.cameraPosition();
        if (!_nodes.length) {
            Vec2f endPos = offset + _needle.cameraPosition();

            Atelier.renderer.drawLine(startPos, endPos, _getThreadColor(startPos, endPos), 1f);
        }
        else {
            int i;
            foreach (node; _nodes) {
                Vec2f endPos = offset + node.cameraPosition();
                Atelier.renderer.drawLine(startPos, endPos, _getThreadColor(startPos, endPos), 1f);
                startPos = endPos;
                i++;
            }
            Atelier.renderer.drawLine(startPos, offset + _needle.cameraPosition(), _getThreadColor(startPos, offset + _needle
                    .cameraPosition()), 1f);
        }
    }

    override EntityGraphic fetch() {
        return new EntityThreadRenderer(this);
    }

    override void setAnchor(Vec2f anchor) {
    }

    override void setPivot(Vec2f pivot) {
    }

    override void setOffset(Vec2f position) {
    }

    override void setAngle(float angle) {
    }

    override void setRotating(bool isRotating) {
    }

    override void setAngleOffset(float angle) {
    }

    override void setEffectMargin(Vec2i margin) {
    }

    override void setBlend(Blend blend) {
    }

    override void setAlpha(float alpha) {
    }

    override void setColor(Color color) {
    }

    override void setScale(Vec2f scale) {
    }

    override void start() {
    }

    override void stop() {
    }

    override void pause() {
    }

    override void resume() {
    }

    override bool isPlaying() const {
        return false;
    }

    override float getLeft(float x) const {
        return x;
    }

    override float getRight(float x) const {
        return x;
    }

    override float getUp(float y) const {
        return y;
    }

    override float getDown(float y) const {
        return y;
    }

    override uint getWidth() const {
        return 0;
    }

    override uint getHeight() const {
        return 0;
    }

    override uint getEffectWidth() const {
        return 0;
    }

    override uint getEffectHeight() const {
        return 0;
    }

    override bool isBehind() const {
        return false;
    }
}

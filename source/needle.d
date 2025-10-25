module needle;

import atelier;

final class NeedleThrowController : Controller!Actor {
    override void onStart() {
        setBehavior(new NeedleThrowBehavior);
    }
}

final class NeedleThrowBehavior : Behavior!Actor {
    private {
        Timer _timer;
        Vec3i _startPoint;
        uint _nodeCount;
        EntityThreadRenderer _renderer;
    }

    override void onStart() {
        entity.setSpeed(2f, 0f);
        entity.setGravity(0f);
        entity.setFrictionBrake(0f);
        entity.setLayer(Entity.Layer.above);

        _startPoint = entity.getPosition();

        _renderer = new EntityThreadRenderer(Atelier.world.player, entity);
        entity.addGraphic("thread", _renderer);
        entity.setAuxGraphic(0, "thread");

        _timer.start(10);
    }

    override void update() {
        _timer.update();

        if (!_timer.isRunning() && _nodeCount < 10) {
            _timer.start(10);

            Actor node = Atelier.res.get!Actor("thread.node");
            node.setPosition(entity.getPosition());
            node.angle = node.angle;
            _renderer.addNode(node);

            _nodeCount++;
        }
    }
}

final class EntityThreadRenderer : EntityGraphic {
    private {
        Entity _player, _needle;
        Actor[] _nodes;
    }

    this(Entity a, Entity b) {
        _player = a;
        _needle = b;
    }

    this(EntityThreadRenderer other) {

    }

    void addNode(Actor node) {
        _nodes ~= node;
    }

    override void update() {
        if (_nodes.length == 1) {
            Vec3f accel = Vec3f.zero;

            Vec3i targetPos = (_player.getPosition() + _needle.getPosition()) / 2;
            accel += (cast(Vec3f)(targetPos - _nodes[0].getPosition())) * .7f;
            _nodes[0].move(accel);
        }
        else {
            foreach (int i; 0 .. cast(int) _nodes.length) {
                Vec3f accel = Vec3f.zero;

                if (i == 0) {
                    Vec3i targetPos = (_player.getPosition() + _nodes[1].getPosition()) / 2;
                    accel += (cast(Vec3f)(targetPos - _nodes[0].getPosition())) * .7f;
                }
                else if (i + 1 == _nodes.length) {
                    Vec3i targetPos = (_nodes[$ - 2].getPosition() + _needle.getPosition()) / 2;
                    accel += (cast(Vec3f)(targetPos - _nodes[$ - 1].getPosition())) * .7f;
                }
                else {
                    Vec3i targetPos = (_nodes[i - 1].getPosition() + _nodes[i + 1].getPosition()) / 2;
                    accel += (cast(Vec3f)(targetPos - _nodes[i].getPosition())) * .7f;
                }

                _nodes[i].move(accel);
            }
        }
    }

    override void draw(Vec2f offset, float alpha = 1f) {
        offset -= _needle.cameraPosition();
        Color[] colors = [Color.red, Color.blue, Color.white];

        Vec2f startPos = offset + _player.cameraPosition();
        if (!_nodes.length) {
            Vec2f endPos = offset + _needle.cameraPosition();

            Atelier.renderer.drawLine(startPos, endPos, Color.red, 1f);
        }
        else {
            int i;
            foreach (node; _nodes) {
                Vec2f endPos = offset + node.cameraPosition();
                Atelier.renderer.drawLine(startPos, endPos, colors[i % 3], 1f);
                startPos = endPos;
                i++;
            }
            Atelier.renderer.drawLine(startPos, offset + _needle.cameraPosition(), colors[i % 3], 1f);
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

    override bool isBehind() const {
        return false;
    }
}

module enemy;

import atelier;

final class EnemyController : Controller!Actor {
    private {
        string _enemyId;
    }

    this(string enemyId) {
        _enemyId = enemyId;
    }

    override void onStart() {
        setBehavior(new EnemyBehavior(_enemyId));
    }
}

final class EnemyBehavior : Behavior!Actor {
    private {
        bool _shot = false;
        int _life;
        string _enemyId;
        GrTask _task;
    }

    this(string enemyId, int life = 5) {
        _enemyId = enemyId;
        _life = life;
    }

    override void onStart() {
        entity.setShadow(true);
        //entity.setFrictionBrake(0f);
        //entity.isHovering(true);
        _task = Atelier.script.callEvent(_enemyId ~ "Behavior", [grGetNativeType("Actor")], [GrValue(entity)]);
    }

    override void update() {
    }
}
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
        string _enemyId;
        GrTask _task;
    }

    this(string enemyId) {
        _enemyId = enemyId;
    }

    override void onStart() {
        _task = Atelier.script.callEvent(_enemyId ~ "Behavior", [grGetNativeType("Actor")], [GrValue(entity)]);
    }

    override void update() {
    }
}
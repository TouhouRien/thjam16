module checkpoint;

import atelier;

final class CheckpointController : Controller!Prop {
    override void onStart() {
        Atelier.log("CHECKPOINT");
    }
}

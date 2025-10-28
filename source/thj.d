module thj;

import atelier;

/// Initialise les ressources
void setupResourceLoaders(ResourceManager res) {
}

/// Renseigne les bibliothèques des scripts
GrModuleLoader[] setupLibLoaders() {
    return [
        &_lib
    ];
}

private void _lib(GrModule library) {
    library.setModule("thjam");

    GrType entityType = grGetNativeType("Entity");

    library.addFunction(&_setAppearFX, "setAppearFX", [entityType]);
}

private void _setAppearFX(GrCall call) {
    Entity entity = call.getNative!Entity(0);
    entity.setEffect(new BlinkEffect(Color.cyan, 0.9f, 0.1f, 60, 3, Spline.sineInOut));
}

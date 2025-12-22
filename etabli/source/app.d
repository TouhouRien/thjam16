import atelier;
import thj;

import std.file : exists;

extern (C) __gshared string[] rt_options = [
    "gcopt=initReserve:128 minPoolSize:256 parallel:2"
];

void main(string[] args) {
    Atelier.openLogger(false);

    try {
        Vec2u windowSize = Vec2u(1920, 1080);
        if (exists("etabli.ffd")) {
            Farfadet ffd = Farfadet.fromFile("etabli.ffd");
            if (ffd.hasNode("windowSize")) {
                windowSize = ffd.getNode("windowSize").get!Vec2u(0);
            }
        }

        Atelier atelier = new Atelier(windowSize.x, windowSize.y, "Établi", &setupResourceLoaders, &setupLibLoaders);

        atelier.etabli.open();
        atelier.run();
        atelier.etabli.close();
        atelier.closeLogger();
    }
    catch (Exception e) {
        Atelier.log("Erreur: ", e.msg);
        foreach (trace; e.info) {
            Atelier.log("à: ", trace);
        }
    }
    finally {
        Atelier.etabli.close();
        Atelier.closeLogger();
    }
}

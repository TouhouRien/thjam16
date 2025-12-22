import atelier;
import thj;

extern (C) __gshared string[] rt_options = [
    "gcopt=initReserve:128 minPoolSize:256 parallel:2"
];

void main(string[] args) {
    Atelier.openLogger(false);

    try {
        Atelier atelier = new Atelier(1280, 720, "Établi", &setupResourceLoaders, &setupLibLoaders);

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

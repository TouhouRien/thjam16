import atelier;

import thj;

extern (C) __gshared string[] rt_options = [
	"gcopt=initReserve:128 minPoolSize:256 parallel:2"
];

void main(string[] args) {
	version (AtelierDebug) {
		Atelier.openLogger(false);
	}
	else {
		Atelier.openLogger(true);
	}

	try {
		startup(args);
	}
	catch (GrCompilerException e) {
		Atelier.log(e.msg);
	}
	catch (Exception e) {
		Atelier.log("Erreur: ", e.msg);
		version (AtelierDebug) {
			foreach (trace; e.info) {
				Atelier.log("à: ", trace);
			}
		}
	}
	finally {
		Atelier.closeLogger();
		Atelier.close();
	}
}

void startup(string[] args) {
	Cli cli = new Cli("atelier");
	cli.setDefault(&cliDefault);

	try {
		cli.parse(args);
	}
	catch (CliException e) {
		Atelier.log("\033[1;91mErreur:\033[0;0m " ~ e.msg);

		if (e.command.length) {
			Atelier.log("\n", cli.getHelp(e.command));
		}
		else {
			Atelier.log("\n", cli.getHelp());
		}
	}
}

void cliDefault(Cli.Result cli) {
	Atelier atelier = new Atelier(false, Atelier_Window_Width,
		Atelier_Window_Height, Atelier_Window_Title, &setupResourceLoaders, &setupLibLoaders);

	atelier.loadArchives();
	atelier.loadResources();

	atelier.window.setIcon(Atelier_Window_Icon);
	atelier.run();
}

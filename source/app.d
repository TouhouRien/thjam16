import atelier;

import thj;
import button;
import chest;
import enemy;
import shinmy;
import needle;
import swing;
import menu;
import mushroom;

import std.stdio;
import checkpoint;

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
		Atelier_Window_Height, "Kobito de l'aiguille étincellante", &setupResourceLoaders, &setupLibLoaders);

	Atelier.window.setSize(1280, 720);
	Atelier.renderer.setScaling(Renderer.Scaling.stretch);
	Atelier.renderer.setPixelSharpness(2);
	//Atelier.window.setDisplay();

	atelier.loadConfig();
	atelier.loadResources();
	atelier.window.setIcon(Atelier_Window_Icon);

	Atelier.input.addAction("left");
	Atelier.input.addAction("right");
	Atelier.input.addAction("up");
	Atelier.input.addAction("down");

	Atelier.input.addAction("needleSwing");
	Atelier.input.addAction("needleThrow");
	Atelier.input.addAction("needlePlant");

	Atelier.input.addActionEvent("left",
		InputEvent.keyButton(InputEvent.KeyButton.Button.a, InputState(KeyState.pressed)));
	Atelier.input.addActionEvent("right",
		InputEvent.keyButton(InputEvent.KeyButton.Button.d, InputState(KeyState.pressed)));
	Atelier.input.addActionEvent("up",
		InputEvent.keyButton(InputEvent.KeyButton.Button.w, InputState(KeyState.pressed)));
	Atelier.input.addActionEvent("down",
		InputEvent.keyButton(InputEvent.KeyButton.Button.s, InputState(KeyState.pressed)));

	Atelier.input.addActionEvent("needleSwing",
		InputEvent.mouseButton(
			InputEvent.MouseButton.Button.left,
			InputState(KeyState.down), 1, Vec2f.zero, Vec2f.zero));
	Atelier.input.addActionEvent("needleThrow",
		InputEvent.mouseButton(
			InputEvent.MouseButton.Button.right,
			InputState(KeyState.down), 1, Vec2f.zero, Vec2f.zero));
	Atelier.input.addActionEvent("needlePlant",
		InputEvent.keyButton(
			InputEvent.KeyButton.Button.e, InputState(KeyState.pressed)
	));

	Atelier.world.addController("control", { return new PlayerController(); });
	Atelier.state.setPlayerController("control");
	Atelier.state.setPlayerActor("shinmy");

	Atelier.world.addController("needleThrow", {
		return new NeedleThrowController();
	});
	Atelier.world.addController("checkpoint", { return new CheckpointController(); });
	Atelier.world.addController("swing", { return new SwingController(); });
	Atelier.world.addController("button", { return new ButtonController(); });
	Atelier.world.addController("toggle", { return new ToggleController(); });
	Atelier.world.addController("suwako", { return new EnemyController("suwako"); });
	Atelier.world.addController("marisa", { return new EnemyController("marisa"); });
	Atelier.world.addController("reimu", { return new EnemyController("reimu"); });
	Atelier.world.addController("yukari", { return new EnemyController("yukari"); });
	Atelier.world.addController("gap", { return new EnemyController("gap"); });
	Atelier.world.addController("kogasa", { return new EnemyController("kogasa"); });
	Atelier.world.addController("yamame", { return new EnemyController("yamame"); });
	Atelier.world.addController("yamameBow", {
		return new EnemyController("yamameBow");
	});
	Atelier.world.addController("tenshi", { return new EnemyController("tenshi"); });
	Atelier.world.addController("mushroom", { return new MushroomController(); });
	Atelier.world.addController("chest", { return new ChestController(); });

	// playTrack
	// stopTrack
	Music overworldMusic = Atelier.res.get!Music("overworld");
	Atelier.audio.playTrack(overworldMusic, 0f);

	Atelier.console.cli.addCommand(&cliReloadScene, "reloadScene", "Recharge le niveau actuel");
	Atelier.renderer.setCursor(Atelier.res.get!Sprite("mallet"));

	Atelier.ui.addUI(new Menu);

	atelier.run();
}

void cliReloadScene(Cli.Result) {
	string scene = Atelier.state.getScene();
	Atelier.world.load(scene);
}

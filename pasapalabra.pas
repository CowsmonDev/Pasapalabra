program pasapalabra;

{
    // le dedico a usted profe la eliminacion de todos los type menos 1;
}

//Declaraciones De Tipos y Constantes:
	type
		ST4=String[4];

	//Jugadores:
		typeJugador = record
			nombre : string;
			partidasGanadas : Integer;
		end;

		puntJugadores = ^typeArbol;
			typeArbol = record
				jugador : typeJugador;
				jugadorMenor : puntJugadores;
				jugadorMayor : puntJugadores;
			end;

		archJugadores = file of typeJugador;

	//Palabras:
		typePalabra = record
			nroSet : Integer;
			letra : String;
			palabra : string;
			consigna : string;
		end;

		archPalabras = file of typePalabra;

	//Partida:

		enumRespuesta = (Pendiente, Acertada, Errada);

		puntRosco = ^typeRosco;
			typeRosco = record
				letra : String;
				palabra : String;
				consigna : String;
				respuesta : enumRespuesta;
				sigConsigna : puntRosco;
			end;

		typePartida = record
			nombreJugador : String;
			rosco : puntRosco;
		end;

		arrayPartida = Array[1..2] of typePartida;

//Metodos Generales:

	{
		si bien este nombre le parece raro a manuel este nombre lo puse haciendo referencia a un metodo que esta presente en java
		por costumbre lo puse asi Y preferiria no cambiarlo... PD: si inciste en cambiarlo lo cambio
	}
	function isExists(var archJugador : archJugadores; Direccion : String): boolean;
	begin
		assign(archJugador,Direccion);
		{$I-}
			reset(archJugador);
		{$I+}
		isExists := (IOResult = 0);
	end;

	function writeMenu(): ST4;
	begin
		writeln('----------------');
		writeln('| PASAPALABRAS |');
		writeln('----------------');
		writeln('1. Agrega un jugador');
		writeln('2. Ver lista de jugadores');
		writeln('3. Jugar');
		writeln('4. Salir');
		writeln('');
		write('Selecciona una opcion: '); Readln(writeMenu);
	end;

	procedure writeArch(var archPalabra : archPalabras);
		var palabra : typePalabra;
	begin
		while not eof(archPalabra) do begin
			read(archPalabra, palabra);
			writeln('El Numero es: ', palabra.nroSet);
			writeln('La letra es: ', palabra.letra);
			writeln('La Palabra es: ', palabra.palabra);
			writeln('');
		end;
	end;

	function isExistsPlayer(Jugadores : puntJugadores; nombre : String) : Boolean;
	begin
		if (Jugadores = Nil) then isExistsPlayer := false
		else if (nombre = Jugadores^.jugador.nombre) then isExistsPlayer := True
		else if nombre < Jugadores^.jugador.nombre then isExistsPlayer := isExistsPlayer(Jugadores^.jugadorMenor,nombre)
		else isExistsPlayer := isExistsPlayer(Jugadores^.jugadorMayor,nombre)
	end;


//Metodos:
	//Agregar un jugador:

		procedure addPlayerTree(var Jugadores : puntJugadores; newJugador : typeJugador);
		begin
			if (Jugadores = Nil) then begin
			new(Jugadores);
			Jugadores^.jugador := newJugador;
			Jugadores^.jugadorMenor := Nil;
			Jugadores^.jugadorMayor := Nil;
			end else if Jugadores^.jugador.nombre < newJugador.nombre then addPlayerTree(Jugadores^.jugadorMayor,newJugador)
			else if Jugadores^.jugador.nombre > newJugador.nombre then addPlayerTree(Jugadores^.jugadorMenor ,newJugador);
		end;


		procedure addPlayer(var archJugador : archJugadores; var Jugadores : puntJugadores);
			var newJugador : typeJugador;
			var respuesta : String;
		begin
			respuesta := 's';
			while respuesta = 's'  do begin
				write('Ingrese el Nombre del Jugador: '); readln(newJugador.nombre);
				newJugador.partidasGanadas := 0;
				if (isExistsPlayer(Jugadores,newJugador.nombre)) then begin
					writeln('Ese Jugador ya existe por favor intentelo nuevamente');
				end else begin
					addPlayerTree(Jugadores,newJugador);
					seek(archJugador, filesize(archJugador));
					write(archJugador,newJugador);
					seek(archJugador,0);
				end;
				write('Quiere cargar otro jugador (s/n): '); readln(respuesta);
			end;
		end;

	//Listar jugadores

		procedure listPayers(Jugador : puntJugadores);
		begin
			if (Jugador <> Nil) then begin
				listPlayers(Jugador^.jugadorMenor);
				writeln('// El Nombre del Jugador es: ', Jugador^.jugador.nombre);
				writeln('// La cantidad de Partidas Ganadas del Jugador es: ', Jugador^.jugador.partidasGanadas);
				writeln('');
				listPlayers(Jugador^.jugadorMayor);
			end;
		end;

	//Jugar:

		procedure writeRosco(rosco : puntRosco);
			var palabra : String;
		begin
			if rosco <> Nil then begin
				palabra := rosco^.palabra;
				repeat
					write('la letra es: '); writeln(rosco^.letra);
					rosco := rosco^.sigConsigna;
				until rosco^.palabra <> palabra;
			end;
		end;

		function createPlayer(jugador : puntJugadores): typePartida;
			var partida : typePartida;
		begin
			partida.rosco := Nil;
			write('escribe el nombre se del jugador: '); readln(partida.nombreJugador);
			while (not isExistsPlayer(jugador,partida.nombreJugador)) do begin
				write('ese nombre no existe, por favor escribe el nombre se del jugador: '); readln(partida.nombreJugador);
			end;
			createPlayer := partida;
		end;

		function createNewRoscoNode(palabra : typePalabra): puntRosco;
			var Rosco : puntRosco;
		begin
			new(Rosco);
			Rosco^.letra := palabra.letra;
			Rosco^.palabra := palabra.palabra;
			Rosco^.consigna := palabra.consigna;
			Rosco^.respuesta := Pendiente;
			Rosco^.sigConsigna := Rosco;
			createNewRoscoNode := Rosco;
		end;

		procedure addRoscoPlay(var Rosco : puntRosco; palabra : typePalabra);
			var cursor : puntRosco;
		begin
			if (Rosco <> Nil) then begin
				cursor := Rosco;
				while (cursor^.sigConsigna^.palabra <> Rosco^.palabra) do cursor := cursor^.sigConsigna;
				cursor^.sigConsigna := createNewRoscoNode(palabra);
				cursor^.sigConsigna^.sigConsigna := Rosco;
			end else Rosco := createNewRoscoNode(palabra);
		end;

		procedure fillRoscoPlay(var archPalabra : archPalabras; var Rosco : puntRosco; indice : Integer);
			var palabra : typePalabra;
		begin
			Seek(archPalabra,0);
			read(archPalabra,palabra);
			while ((not eof(archPalabra)) and (palabra.nroSet <= indice)) do begin
				if (palabra.nroSet = indice) then addRoscoPlay(Rosco,palabra);
				read(archPalabra,palabra);
			end;
		end;

		function getQuestionPending(rosco : puntRosco): puntRosco;
			var palabra : String;
		begin
			palabra := rosco^.palabra;
			while ((rosco^.palabra <> palabra) and (rosco^.respuesta <> Pendiente)) do rosco := rosco^.sigConsigna;
			if rosco^.respuesta = Pendiente then getQuestionPending := rosco else getQuestionPending := Nil;
		end;

		function getAnswer(pregunta : puntRosco) : String;
		begin
			writeln('La letra es: ', pregunta^.letra);
			writeln('La letra es: ', pregunta^.consigna);
			write('Ingrese su respuesta, (escribe "pp" para pasapalabra): ', getAnswer);
		end;

		procedure initGame(var partida : arrayPartida);
			var numJugador : Integer;
		begin
			numJugador := 1;
			partida[numJugador].rosco := getQuestionPending(partida[numJugador].rosco);
			while ((partida[1].rosco <> Nil) and (partida[2].rosco <> Nil)) do begin
				if partida[numJugador].rosco <> Nil then begin
					respuesta := getAnswer(partida[numJugador].rosco);
					if respuesta <> 'pp' then if numJugador = 1 then numJugador = 2 else numJugador = 1;
					else if (partida[numJugador].rosco^.partida = respuesta) then partida[numJugador].rosco^.respuesta := Acertada
					else begin
						partida[numJugador].rosco^.respuesta := Errada;
						if numJugador = 1 then numJugador = 2 else numJugador = 1;
					end;
					partida[numJugador].rosco := getQuestionPending(partida[numJugador].rosco);
				end;
			end;
		end;


		function getCorrectAmount(rosco : puntRosco): Integer;
			var cantidadCorrectas : Integer;
			var palabra : String;
		begin
			palabra := rosco^.palabra;
			cantidadCorrectas := 0;
			repeat
				if rosco^.respuesta = Acertada then cantidadCorrectas := cantidadCorrectas + 1;
				rosco := rosco^.sigConsigna;
			until rosco^.palabra <> palabra;
			getCorrectAmount := cantidadCorrectas;
		end;

		procedure finishGame(var archJugador : archJugadores; var Jugadores : puntJugadores; partida : arrayPartida);
			var puntajeJugador1, puntajeJugador2 : Integer;
		begin
			puntajeJugador1 := getCorrectAmount(partida[1].rosco);
			puntajeJugador2 := getCorrectAmount(partida[2].rosco);

			if puntajeJugador1 = puntajeJugador2 then begin
				//Empate
			end else if puntajeJugador1 < puntajeJugador2 then begin
				//gana jugador 1
			end else begin
				//gana jugador 2
			end;
		end;


		procedure play(var archPalabra : archPalabras; var archJugador : archJugadores; var Jugadores : puntJugadores);
			var partida : arrayPartida;
		begin
			partida[1] := createPlayer(Jugadores);
			fillRoscoPlay(archPalabra, partida[1].rosco, 2);
			partida[2] := createPlayer(Jugadores);
			fillRoscoPlay(archPalabra, partida[2].rosco, 3);
			initGame(partida);
		end;

	//Salir:
		procedure exitPlay(var archPalabra : archPalabras; var archJugador : archJugadores);
		begin
			writeln('');
			writeln('--------------------------------------------');
			writeln('| Esta saliendo del juego vuelva pronto!!! |');
			writeln('--------------------------------------------');
			writeln('');
			close(archPalabra);
			close(archJugador);
		end;

		//Selector:

		procedure fillTreePlayer(var archJugador : archJugadores; var Jugador : puntJugadores);
			var newJugador : typeJugador;
		begin
			while not eof(archJugador) do begin
				read(archJugador,newJugador);
				addPlayerTree(Jugador, newJugador);
			end;
		end;

		procedure selectMode(var archPalabra : archPalabras; var archJugador : archJugadores; var Jugadores : puntJugadores);
			var Mode : ST4;
		begin
			Mode := 's';
			while Mode = 's' do begin
				Mode :=  writeMenu();
				while(Mode <> '4') do begin
					Case Mode of
						'1' : addPlayer(archJugador,Jugadores);
						'2' : listPlayers(Jugadores);
						'3' : play(archPalabra,archJugador,Jugadores);
						else begin
							writeln('Esa Opcion no existe');
							writeln('');
							writeln('////////\\\\\\\\');
							writeln('');
							Mode := writeMenu();
						end;
					end;
				end;
				WriteLn('');
				Write('Quiere usted continuar? (s/n): '); ReadLn(Mode);
			end;
			exitPlay(archPalabra,archJugador);
		end;

//variables:
var archPalabra : archPalabras;
var archJugador : archJugadores;
var Jugadores : puntJugadores;

begin
	jugadores := Nil;
	if (not isExists(archJugador,'./ip2/Acrespo-Jugadores.dat')) then rewrite(archJugador);
	assign(archPalabra,'./ip2/palabras.dat');
	reset(archPalabra);
	fillTreePlayer(archJugador,Jugadores);
	selectMode(archPalabra,archJugador,Jugadores);
end.

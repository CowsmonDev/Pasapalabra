program pasapalabras;

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

		//segun la profe esto no representa una lista circular
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

//Metodos:
	//Agregar un jugador:

		function createPlayer():puntJugadores;
			var newJugador : puntJugadores;
		begin
			new(newJugador);
			write('Ingrese el Nombre del Jugador: '); readln(newJugador^.jugador.nombre);
			newJugador^.jugador.partidasGanadas := 0;
			newJugador^.jugadorMayor := Nil;
			newJugador^.jugadorMenor:= Nil;
			createPlayer := newJugador;
		end;
		function createPlayer(Jugador : typeJugador): puntJugadores;
			var newJugador : puntJugadores;
		begin
			new(newJugador);
			newJugador^.jugador := Jugador;
			newJugador^.jugadorMayor := Nil;
			newJugador^.jugadorMenor:= Nil;
			createPlayer := newJugador;
		end;

		function addPlayerTree(var Jugadores : puntJugadores; newJugador : puntJugadores) : boolean;
		begin
				if (Jugadores = Nil) then begin
					Jugadores := newJugador;
					addPlayerTree := false;
				end else if (newJugador^.jugador.nombre = Jugadores^.jugador.nombre) then addPlayerTree := true
				else if newJugador^.jugador.nombre < Jugadores^.jugador.nombre then addPlayerTree(Jugadores^.jugadorMenor,newJugador)
				else addPlayerTree(Jugadores^.jugadorMayor,newJugador)
		end;

		procedure addPlayer(var archJugador : archJugadores; var Jugadores : puntJugadores);
			var newJugador : puntJugadores;
			var respuesta : String;
		begin
			respuesta := 's';
			while respuesta = 's'  do begin
				newJugador := createPlayer();
				if addPlayerTree(Jugadores,newJugador) then begin
					writeln('Ese Jugador ya existe por favor intentelo nuevamente');
				end else begin
					seek(archJugador, filesize(archJugador));
					write(archJugador,newJugador^.jugador);
					seek(archJugador,0);
				end;
				write('Quiere cargar otro jugador (s/n): '); readln(respuesta);
			end;
		end;

	//Listar jugadores

		procedure fillTreePlayer(var archJugador : archJugadores; var Jugador : puntJugadores);
			var newJugador : typeJugador;
		begin
			while not eof(archJugador) do begin
				read(archJugador,newJugador);
				addPlayerTree(Jugador,createPlayer(newJugador));
			end;
		end;

		procedure listPayers(Jugador : puntJugadores);
		begin
			if (Jugador <> Nil) then begin
				listPayers(Jugador^.jugadorMenor);
				writeln('// El Nombre del Jugador es: ', Jugador^.jugador.nombre);
				writeln('// La cantidad de Partidas Ganadas del Jugador es: ', Jugador^.jugador.partidasGanadas);
				writeln('');
				listPayers(Jugador^.jugadorMayor);
			end;
		end;

	//Jugar:

		{function fillRoscoPlay(var archPalabra : archPalabras; indice : Integer) : puntRosco;
			var palabra : typePalabra;
			var rosco : puntRosco;
			begin
				new(puntRosco);
				puntRosco := Nil;
				fillRoscoPlay := puntRosco;
				Read(archPalabra, palabra);
			while (not eof(archPalabra)) and (indice <= palabra^.nroSet) do begin
				puntRosco := palabra;
				puntRosco := puntRosco^.sigConsigna
				read(archPalabra,palabra);
			end;
		end;
		}
		procedure writeRosco(rosco : puntRosco);
		begin
		end;

		function fillRoscoPlay(var archPalabra : archPalabras; var rosco : puntRosco; indice : Integer) : puntRosco;
			var palabra : typePalabra;
		begin
			if (not eof(archPalabra)) then begin
				read(archPalabra,palabra);
				if indice <= palabra.nroSet then begin
					rosco^.letra := palabra.letra;
					rosco^.consigna := palabra.consigna;
					rosco^.respuesta := Pendiente;
					rosco^.sigConsigna := fillRoscoPlay(archPalabra,rosco^.sigConsigna,indice);
				end else rosco := Nil;
				fillRoscoPlay := rosco;
			end;
		end;

		function isExistsPlayer(jugador : puntJugadores; nombre : String) : boolean;
		begin
			if jugador = Nil then isExistsPlayer := false
			else if jugador^.jugador.nombre = nombre then isExistsPlayer := true
			else if jugador^.jugador.nombre > nombre then isExistsPlayer := isExistsPlayer(jugador^.jugadorMenor,nombre)
			else isExistsPlayer := isExistsPlayer(jugador^.jugadorMayor,nombre);
		end;

		function createPlayer(jugador : puntJugadores): typePartida;
			var partida : typePartida;
		begin
			new(partida.rosco);
			partida.rosco := Nil;
			write('escribe el nombre se del jugador: '); readln(partida.nombreJugador);
			while (not isExistsPlayer(jugador,partida.nombreJugador)) do begin
				write('ese nombre no existe, por favor escribe el nombre se del jugador: '); readln(partida.nombreJugador);
			end;
			createPlayer := partida;
		end;

		function fillArrayPlay(var archPalabra : archPalabras; jugador : puntJugadores) : arrayPartida;
			var partida : arrayPartida;
		begin
			partida[1] := createPlayer(jugador);
			partida[1].rosco := fillRoscoPlay(archPalabra,partida[1].rosco,2);
			partida[2] := createPlayer(jugador);
			partida[2].rosco := fillRoscoPlay(archPalabra,partida[2].rosco,3);
			fillArrayPlay := partida;
		end;

		procedure play(var archPalabra : archPalabras; var archJugador : archJugadores; var Jugadores : puntJugadores);
			var partida : arrayPartida;
		begin
			partida := fillArrayPlay(archPalabra,Jugadores);
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

//variables:
var archPalabra : archPalabras;
var archJugador : archJugadores;
var Jugadores : puntJugadores;
var Mode : ST4;

begin
	jugadores := Nil;

	if (not isExists(archJugador,'ip2/Acrespo-Jugadores.dat')) then rewrite(archJugador);
	assign(archPalabra,'ip2/palabras.dat');
	reset(archPalabra);

	{
		// esta seccion contiene el codigo que muestra el menu y elige que metodo quiere ejecutar;
		// PD: esto no esta en un procedimiento debido a la cantidad de variables que tendria que haber pasado por parametro;
	}

	fillTreePlayer(archJugador,Jugadores);

	Mode :=  writeMenu();
		while(Mode <> '4') do begin
			Case Mode of
				'1' : addPlayer(archJugador,Jugadores);
				'2' : listPayers(Jugadores);
				'3' : play(archPalabra,archJugador,Jugadores);
				else begin
					writeln('Esa Opcion no existe');
					writeln('');
					writeln('////////\\\\\\\\');
					writeln('');
				end;
			end;
			Mode := writeMenu();
		end;
		exitPlay(archPalabra,archJugador);
end.

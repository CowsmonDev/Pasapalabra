program pasapalabras;

//Declaraciones De Tipos y Constantes:

	//Jugadores:
		type typeJugador = record
			nombre : string;
			partidasGanadas : Integer;
		end;

		type puntJugadores = ^typeArbol;
			typeArbol = record
				jugador : typeJugador;
				jugadorMenor : puntJugadores;
				jugadorMayor : puntJugadores;
			end;

		type archJugador = file of typeJugador;

	//Palabras:
		type typePalabra = record
			nroSet : Integer;
			letra : String;
			palabra : string;
			consigna : string;
		end;

		type archPalabras = file of typePalabra;

	//Partida:

		type enumRespuesta = (Pendiente, Acertada, Errada);

		type puntRosco = ^typeRosco;
			typeRosco = record
				letra : Integer;
				palabra : String;
				consigna : String;
				respuesta : enumRespuesta;
			end;

		type typePartida = record
			nombreJugador : String;
			rosco : puntRosco;
		end;

		type arrayPartida = Array[1..2] of typePartida;

//Metodos Generales:

	function isExists(var Jugador : archJugador; Direccion : String): boolean;
	begin
		assign(Jugador,Direccion);
		{$I-}
			reset(Jugador);
		{$I+}
		isExists := (IOResult = 0);
	end;

	procedure isExists(var Palabras: archPalabras; Direccion, aviso : String);
	begin
		assign(Palabras,Direccion);
		{$I-}
			reset(Palabras);
		{$I+}
		if IOResult <> 0 then begin
			writeln(aviso);
			HALT;
		end;
	end;

	function writeMenu(): String;
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

		procedure addPlayer();
		begin

		end;

	//Listar jugadores
		procedure listPayers();
		begin

		end;

	//Jugar:
		procedure play();
		begin

		end;

	//Salir:
		procedure exitPlay(var Palabras : archPalabras; var Jugador : archJugador);
		begin
			writeln('');
			writeln('--------------------------------------------');
			writeln('| Esta saliendo del juego vuelva pronto!!! |');
			writeln('--------------------------------------------');
			writeln('');
			close(Palabras);
			close(Jugador);
			HALT;
		end;

	procedure selectMode(var Palabras : archPalabras; var Jugador : archJugador);
		var Mode : String;
	begin
		Mode :=  writeMenu();
		while(Mode <> '4') do begin
			Case Mode of
				'1' : addPlayer();
				'2' : listPayers();
				'3' : play();
				else begin
					writeln('Esa Opcion no existe');
					writeln('');
					writeln('////////\\\\\\\\');
					writeln('');
				end;
			end;
			Mode := writeMenu();
		end;
		exitPlay(Palabras,Jugador);
	end;

//variables:
var Palabras : archPalabras;
var Jugador : archJugador;
begin
	if not isExists(Jugador,'ip2/Acrespo-Jugadores.dat') then rewrite(Jugador);
	isExists(Palabras,'ip2/palabras.dat','Error: lo sentimos, pero el archivo Palabras no se pudo abrir');
	selectMode(Palabras,Jugador);
end.

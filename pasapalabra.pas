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

		type archJugadores = file of typeJugador;

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

	function isExists(var archJugador : archJugadores; Direccion : String): boolean;
	begin
		assign(archJugador,Direccion);
		{$I-}
			reset(archJugador);
		{$I+}
		isExists := (IOResult = 0);
	end;

	procedure isExists(var archPalabra: archPalabras; Direccion, aviso : String);
	begin
		assign(archPalabra,Direccion);
		{$I-}
			reset(archPalabra);
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

		function isExistsPlayer(var Jugadores : puntJugadores; newJugador : puntJugadores) : boolean;
		begin
				if (Jugadores = Nil) then begin
					Jugadores := newJugador;
					isExistsPlayer := false;
				end else if (newJugador^.jugador.nombre = Jugadores^.jugador.nombre) then isExistsPlayer := true
				else if newJugador^.jugador.nombre < Jugadores^.jugador.nombre then isExistsPlayer(Jugadores^.jugadorMenor,newJugador)
				else isExistsPlayer(Jugadores^.jugadorMayor,newJugador)
		end;

		procedure addPlayer(var archJugador : archJugadores; var Jugadores : puntJugadores);
			var newJugador : puntJugadores;
			var respuesta : String;
		begin
			respuesta := 's';
			while respuesta = 's'  do begin
				newJugador := createPlayer();
				if isExistsPlayer(Jugadores,newJugador) then begin
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
		procedure listPayers();
		begin

		end;

	//Jugar:
		procedure play();
		begin

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
			HALT;
		end;

//variables:
var archPalabra : archPalabras;
var archJugador : archJugadores;
var Jugadores : puntJugadores;
var Mode : String;

begin
	jugadores := Nil;
	if not isExists(archJugador,'ip2/Acrespo-Jugadores.dat') then rewrite(archJugador);
	isExists(archPalabra,'ip2/palabras.dat','Error: lo sentimos, pero el archivo Palabras no se pudo abrir');

	{
		// esta seccion contiene el codigo que muestra el menu y elige que metodo quiere ejecutar;
		// PD: esto no esta en un procedimiento debido a la cantidad de variables que tendria que haber pasado por parametro;
	}
	Mode :=  writeMenu();
		while(Mode <> '4') do begin
			Case Mode of
				'1' : addPlayer(archJugador,Jugadores);
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
		exitPlay(archPalabra,archJugador);

end.

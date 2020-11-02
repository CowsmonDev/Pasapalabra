program pasapalabras;

//Declaraciones:

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

function isExists(var arch : archJugador; Direccion : String): boolean;
begin
	assign(arch,Direccion);
	{$I-}
		reset(arch);
	{$I+}
	isExists := (IOResult = 0);
end;

procedure isExists(var arch : archPalabras; Direccion, aviso : String);
begin
	assign(arch,Direccion);
	{$I-}
		reset(arch);
	{$I+}
	if IOResult <> 0 then begin
		writeln(aviso);
		exit
	end;
end;

//Metodos:

var Palabras : archPalabras;
var Jugador : archJugador;

begin
	if not isExists(Jugador,'ip2/Acrespo-Jugadores.dat') then rewrite(Jugador);
	isExists(Palabras,'ip2/palabras.dat','Error: lo sentimos, pero el archivo Palabras no se pudo abrir');
end.

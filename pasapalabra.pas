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

		typeArchJugadores = file of typeJugador;

	//Palabras:
		typePalabra = record
			nroSet : Integer;
			letra : String;
			palabra : string;
			consigna : string;
		end;

		typeArchPalabras = file of typePalabra;

	//Partida:

		enumRespuesta = (Pendiente, Acertada, Errada);

		puntRosco = ^typeRosco;
			typeRosco = record
				letra : String;  // STRING[1]
				palabra : String;
				consigna : String;
				respuesta : enumRespuesta;
				sigConsigna : puntRosco;
			end;

		typePartida = record
			nombreJugador : String;
			rosco : puntRosco;
		end;

		typeArrayPartida = Array[1..2] of typePartida;

//Metodos Generales:

	{
		si bien este nombre le parece raro a manuel este nombre lo puse haciendo referencia a un metodo que esta presente en java
		por costumbre lo puse asi Y preferiria no cambiarlo... PD: si inciste en cambiarlo lo cambio
	}
	// COINCIDO CON MANUEL EN QUE RESULTA CONFUSA TU FORMA DE NOMBRAR MODULOS, TENES QUE APUNTAR A QUE TUS CODIGOS SEAN ENTENDIBLES EN PASCAL 
	// (SIN NECESIDAD QUE QUIEN LOS LEA SEA EXPERTO EN JAVA) YM
	
	function existeArchivo(var archJugador : typeArchJugadores; Direccion : String): boolean; 
	begin
		assign(archJugador,Direccion);
		{$I-}
			reset(archJugador);
		{$I+}
		existeArchivo := (IOResult = 0);
	end;



	procedure escribirArchivo(var archPalabra : typeArchPalabras);
		var palabraActual : typePalabra; 
	begin
		while not eof(archPalabra) do begin
			read(archPalabra, palabraActual);
			writeln('El Numero es: ', palabraActual.nroSet);
			writeln('La letra es: ', palabraActual.letra);
			writeln('La Palabra es: ', palabraActual.palabra); 
			writeln('');
		end;
	end;

	function existeJugador(arbolJugadores : puntJugadores; nombre : String) : Boolean;
	begin
		if (arbolJugadores = Nil) then existeJugador := false
		else if (nombre = arbolJugadores^.jugador.nombre) then existeJugador:= True
		else if nombre < arbolJugadores^.jugador.nombre then existeJugador:= existeJugador(arbolJugadores^.jugadorMenor,nombre)
		else existeJugador := existeJugador(arbolJugadores^.jugadorMayor,nombre)
	end;


//Metodos:
	//Agregar un jugador:

		procedure agregarJugadorArbol(var arbolJugadores : puntJugadores; nuevoNombre : String);
		begin
			if (arbolJugadores = Nil) then begin
				new(arbolJugadores);                 // NEW(JUGADORES) SINTAXIS MUY SIMILAR A NEWJUGADOR. CONFUNDE. YM 
				arbolJugadores^.jugador.nombre := nuevoNombre;
				arbolJugadores^.jugador.partidasGanadas := 0;
				arbolJugadores^.jugadorMenor := Nil;
				arbolJugadores^.jugadorMayor := Nil;
			end else if arbolJugadores^.jugador.nombre < nuevoNombre then agregarJugadorArbol(arbolJugadores^.jugadorMayor,nuevoNombre)
			else if arbolJugadores^.jugador.nombre > nuevoNombre then agregarJugadorArbol(arbolJugadores^.jugadorMenor ,nuevoNombre);
		end;


		procedure agregarJugador(var archJugador : typeArchJugadores; var arbolJugadores : puntJugadores);
			var nuevoJugador : typeJugador;
			var respuesta : String; // STRING[1] YM
		begin
			respuesta := 's';
			nuevoJugador.partidasGanadas := 0;
			while respuesta = 's'  do begin
				write('Ingrese el Nombre del Jugador: '); readln(nuevoJugador.nombre);
				if (existeJugador(arbolJugadores,nuevoJugador.nombre)) then writeln('Ese Jugador ya existe por favor intentelo nuevamente')
				else begin
					agregarJugadorArbol(arbolJugadores,nuevoJugador.nombre);
					seek(archJugador, filesize(archJugador));
					write(archJugador,nuevoJugador);
					seek(archJugador,0);
				end;
				write('Quiere cargar otro jugador (s/n): '); readln(respuesta);
			end;
		end;

	//Listar jugadores

		procedure listarJugadores(var arbolJugadores : puntJugadores);
		begin
			if (arbolJugadores <> Nil) then begin
				listarJugadores(arbolJugadores^.jugadorMenor);
				writeln('// El Nombre del Jugador es: ', arbolJugadores^.jugador.nombre);
				writeln('// La cantidad de Partidas Ganadas del Jugador es: ', arbolJugadores^.jugador.partidasGanadas);
				writeln('');
				listarJugadores(arbolJugadores^.jugadorMayor);
			end;
		end;

	//Jugar:

		function crearJugador(arbolJugadores : puntJugadores): typePartida;
			var partida : typePartida;
		begin
			partida.rosco := Nil;
			write('escribe el nombre se del jugador: '); readln(partida.nombreJugador);
			while (not existeJugador(arbolJugadores,partida.nombreJugador)) do begin
				write('ese nombre no existe, por favor escribe el nombre se del jugador: '); readln(partida.nombreJugador);
			end;
			crearJugador := partida;
		end;

		function crearNuevoRosco(nuevaPalabra : typePalabra): puntRosco;
			var Rosco : puntRosco;
		begin
			new(Rosco);
			Rosco^.letra := nuevaPalabra.letra;
			Rosco^.palabra := nuevaPalabra.palabra;
			Rosco^.consigna := nuevaPalabra.consigna;
			Rosco^.respuesta := Pendiente;
			Rosco^.sigConsigna := Rosco;
			crearNuevoRosco := Rosco;
		end;

		procedure agregarNuevoRosco(var Rosco : puntRosco; palabra : typePalabra);
			var cursor : puntRosco;
		begin
			if (Rosco <> Nil) then begin
				cursor := Rosco;
				while (cursor^.sigConsigna^.palabra <> Rosco^.palabra) do cursor := cursor^.sigConsigna;
				cursor^.sigConsigna := crearNuevoRosco(palabra);
				cursor^.sigConsigna^.sigConsigna := Rosco;
			end else Rosco := crearNuevoRosco(palabra);
		end;

		procedure llenarRoscoPartida(var archPalabra : typeArchPalabras; var Rosco : puntRosco; indice : Integer);
			var palabra : typePalabra;
		begin
			Seek(archPalabra,0);
			palabra.nroSet := 0;
			while ((not eof(archPalabra)) and (palabra.nroSet <= indice)) do begin  // READ( ARCHPALABRA, PALABRA)  YM
			    read(archPalabra,palabra);
				if (palabra.nroSet = indice) then agregarNuevoRosco(Rosco,palabra);
			end;
		end;

		function existePreguntaPendiente(var rosco : puntRosco): Boolean;
			var palabra : String;
		begin
			palabra := rosco^.palabra;
			if rosco^.respuesta = Pendiente then existePreguntaPendiente := true 
			else begin
				repeat
				rosco := rosco^.sigConsigna;
				until ((rosco^.palabra <> palabra) or (rosco^.respuesta <> Pendiente));
				existePreguntaPendiente := (rosco^.respuesta = Pendiente);
			end;
		end;

		function obtenerRespuesta(pregunta : puntRosco) : String;
			var respuesta : String;
		begin
			writeln('La Letra es: ', pregunta^.letra);
			writeln('La Consigna es: ', pregunta^.consigna);
			write('Ingrese su respuesta, (escribe "pp" para pasapalabra): '); ReadLn(respuesta);
			obtenerRespuesta:= respuesta;
		end;

		procedure initGame(var partida : typeArrayPartida);
			var numJugador : Integer;
			var respuesta : String;
		begin
			numJugador := 1;
			while (existePreguntaPendiente(partida[numJugador].rosco)) do begin
				respuesta := obtenerRespuesta(partida[numJugador].rosco);
				if respuesta = 'pp' then begin if numJugador = 1 then numJugador := 2 else numJugador := 1;
				end else if partida[numJugador].rosco^.palabra = respuesta then partida[numJugador].rosco^.respuesta := Acertada
				else begin
					partida[numJugador].rosco^.respuesta := Errada;
					if numJugador = 1 then numJugador := 2 else numJugador := 1;
				end;
			end;
		end;

		function obtenerCantidadCorrectas(rosco : puntRosco): Integer;
			var cantidadCorrectas : Integer;
			var palabraInicial: String;
		begin
			palabraInicial := rosco^.palabra;
			cantidadCorrectas := 0;
			repeat
				if rosco^.respuesta = Acertada then cantidadCorrectas := cantidadCorrectas + 1;
				rosco := rosco^.sigConsigna;
			until rosco^.palabra <> palabraInicial;
			obtenerCantidadCorrectas := cantidadCorrectas;
		end;

		procedure modificarPuntajeArbol(arbolJugadores : puntJugadores; nombre : String);
		begin
			if arbolJugadores^.jugador.nombre = nombre then arbolJugadores^.jugador.partidasGanadas := arbolJugadores^.jugador.partidasGanadas + 1
			else if arbolJugadores^.jugador.nombre < nombre then modificarPuntajeArbol(arbolJugadores^.jugadorMayor ,nombre)
			else if arbolJugadores^.jugador.nombre > nombre then modificarPuntajeArbol(arbolJugadores^.jugadorMenor ,nombre);
		end;

		procedure modificarPuntajeArchivo(var archJugador : typeArchJugadores; nombre : String);
			var jugador : typeJugador;
		begin
			Seek(archJugador,0);
			repeat Read(archJugador,jugador);
			until(jugador.nombre <> nombre);
			jugador.partidasGanadas := jugador.partidasGanadas + 1;
			Write(archJugador, jugador);
			Seek(archJugador,0);
		end;

		procedure terminarJuego(var archJugador : typeArchJugadores; var arbolJugadores : puntJugadores; partida : typeArrayPartida);
			var puntajeJugador1, puntajeJugador2 : Integer;
		begin
			puntajeJugador1 := obtenerCantidadCorrectas(partida[1].rosco);
			puntajeJugador2 := obtenerCantidadCorrectas(partida[2].rosco);

			if puntajeJugador1 > puntajeJugador2 then begin
				modificarPuntajeArbol(arbolJugadores, partida[1].nombreJugador);
				modificarPuntajeArchivo(archJugador, partida[1].nombreJugador);
			end else if puntajeJugador1 < puntajeJugador2 then begin
				modificarPuntajeArbol(arbolJugadores, partida[2].nombreJugador);
				modificarPuntajeArchivo(archJugador, partida[2].nombreJugador);
			end;
		end;


		procedure jugar(var archPalabra : typeArchPalabras; var archJugador : typeArchJugadores; arbolJugadores : puntJugadores);
			var partida : typeArrayPartida;
		begin
			Randomize;
			partida[1] := crearJugador(arbolJugadores);
			llenarRoscoPartida(archPalabra, partida[1].rosco, Random(5)+1);
			partida[2] := crearJugador(arbolJugadores);
			llenarRoscoPartida(archPalabra, partida[2].rosco, Random(5)+1);
			initGame(partida);
			terminarJuego(archJugador,arbolJugadores,partida);
		end;

	//Salir:
		procedure salirJuego(var archPalabra : typeArchPalabras; var archJugador : typeArchJugadores);
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

		procedure llenarArbolJugador(var archJugador : typeArchJugadores; var arbolJugador : puntJugadores);
			var newJugador : typeJugador;
		begin
			while not eof(archJugador) do begin
				read(archJugador,newJugador);
				agregarJugadorArbol(arbolJugador, newJugador.nombre);
			end;
		end;

		function escribirMenu(): ST4;  // CON STRING[1] ALCANZA... 
		//respondiendo a la correccion: ya habia comentado que utilice cuatro en string debido a que si me ingresaba un numero de dos cifraz me tomaba el primero, por lo que el 10 seria enrealidad 1
		begin
			writeln('----------------');
			writeln('| PASAPALABRAS |');
			writeln('----------------');
			writeln('1. Agrega un jugador');
			writeln('2. Ver lista de jugadores');
			writeln('3. Jugar');
			writeln('4. Salir');
			writeln('');
			write('Selecciona una opcion: '); Readln(escribirMenu);
		end;

		procedure seleccionarModo(var archPalabra : typeArchPalabras; var archJugador : typeArchJugadores; var arbolJugadores : puntJugadores);
			var Mode : ST4;
		begin
			Mode := 's';
			while Mode = 's' do begin
				Mode :=  escribirMenu();
				while(Mode <> '4') do begin
					Case Mode of
						'1' : agregarJugador(archJugador,arbolJugadores);
						'2' : listarJugadores(arbolJugadores);
						'3' : jugar(archPalabra,archJugador,arbolJugadores);
						else begin
							writeln('Esa Opcion no existe');
							writeln('');
							writeln('////////\\\\\\\\');
							writeln('');
							Mode := escribirMenu();
						end;
					end;
					WriteLn('');
					Write('Quiere usted continuar? (s/n): '); ReadLn(Mode);
				end;
			end;
			salirJuego(archPalabra,archJugador);
		end;

//variables:
var archPalabra : typeArchPalabras;
var archJugador : typeArchJugadores;
var arbolJugadores : puntJugadores;

begin
	arbolJugadores := Nil;
	if (not existeArchivo(archJugador,'./ip2/Acrespo-Jugadores.dat')) then rewrite(archJugador);
	assign(archPalabra,'./ip2/palabras.dat');
	reset(archPalabra);
	llenarArbolJugador(archJugador,arbolJugadores);
	seleccionarModo(archPalabra,archJugador,arbolJugadores);
end.
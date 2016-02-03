with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

procedure Main is
   type Tarea is record
      wcet, deadline, period, wcrt:integer;
      prio, util: float; --menor valor => mayor prioridad
   end record;

   Num_tasks: integer:=3;
   type carga is array (1..num_tasks) of Tarea;
   Tareas: carga;
   c: character;

   function test_inicial return boolean is
   begin
      for j in 1..Num_Tasks loop
         if Tareas(j).deadline /= Tareas(j).period then
            return FALSE; -- Los plazos de las tareas son distintos de los periodos
         end if;
      end loop;
      return TRUE; -- Todos los plazos coinciden con los periodos
   end test_inicial;

   function test_factor_utilizacion(n : Float) return boolean is
      total : Float := 0.0;
      operacion : Float;
   begin
      for i in 1..integer(n) loop
         total:=total+float(Tareas(i).wcet)/float(Tareas(i).period);
      end loop;
      operacion := n*(2.0**(1.0/n)-1.0);
      if total <= operacion then
         return TRUE;
      else
         return FALSE;
      end if;
   end test_factor_utilizacion;

   procedure ordenar_deadline_monotonic is
      aux : Tarea;
   begin
      for j in 1..Num_Tasks loop
         if Tareas(j).deadline > Tareas(j+1).deadline then
            aux := Tareas(j);
            Tareas(j) := Tareas(j+1);
            Tareas(j+1) := aux;
         end if;
         end loop;
   end ordenar_deadline_monotonic;

   procedure imprimir is
   begin
      for i in 1..Num_tasks loop
         put(Tareas(i).wcet);
         new_line;
      end loop;
   end imprimir;

   function test_tiempo_respuesta_individual(x : Integer) return boolean is
      W_ant, W, interferencia : Float := 0.0;
   begin
      if x = 1 then -- Caso particular Tarea 1
         if Tareas(x).wcet <= Tareas(x).period then
            return TRUE;
         end if;
      end if;

      W_ant := float(Tareas(x).wcet); -- Primera iteración
      while W <= float(Tareas(x).period) loop
         interferencia := 0.0;
         for j in 1..(x-1) loop -- Cálculo interferencias
            interferencia := interferencia+Float'Ceiling(W_ant/float(Tareas(j).period))*float(Tareas(j).wcet);
         end loop;
         W := float(Tareas(x).wcet)+interferencia;
         put(W, Aft=>1, Exp=>0);
         put(interferencia, Aft=>1, Exp=>0);
         new_line;
         if W = W_ant then
            if W <= float(Tareas(x).period) then
               return TRUE; -- Tarea apta
            end if;
         else
            W_ant := W;
         end if;
      end loop;
      return FALSE; -- Tarea no apta
   end test_tiempo_respuesta_individual;

   function test_tiempo_respuesta return boolean is
   begin
      for i in 1..Num_Tasks loop
         if test_tiempo_respuesta_individual(i) = FALSE then
            return FALSE;
         end if;
      end loop;
      return TRUE;

   end test_tiempo_respuesta;

begin
   -- A continuación se encuentran todas los conjuntos a evaluar
   -- Presionar "ctrl" + "-" para comentar y "ctrl" + "shift" + "-" para descomentar
   -- Nota: Tener en cuenta cambiar el valor de Num_tasks al número de tareas a evaluar

--     Tareas(1):=(2,10,10,0,0.0,0.0);
--     Tareas(2):=(4,18,18,0,0.0,0.0);
--     Tareas(3):=(6,24,24,0,0.0,0.0);

   -- Conjunto 1
   Tareas(1):=(1,4,4,0,0.0,0.0);
   Tareas(2):=(2,8,8,0,0.0,0.0);
   Tareas(3):=(4,12,12,0,0.0,0.0);

   -- Conjunto 2
--     Tareas(1):=(2,10,10,0,0.0,0.0);
--     Tareas(2):=(4,15,15,0,0.0,0.0);
--     Tareas(3):=(5,25,25,0,0.0,0.0);
--     Tareas(4):=(6,35,35,0,0.0,0.0);

   -- Conjunto 3
--     Tareas(1):=(2,10,12,0,0.0,0.0);
--     Tareas(2):=(4,15,16,0,0.0,0.0);
--     Tareas(3):=(5,18,20,0,0.0,0.0);
--     Tareas(4):=(6,21,35,0,0.0,0.0);

   -- Conjunto 4
--     Tareas(1):=(2,10,14,0,0.0,0.0);
--     Tareas(2):=(2,10,12,0,0.0,0.0);
--     Tareas(3):=(2,10,18,0,0.0,0.0);
--     Tareas(4):=(2,10,24,0,0.0,0.0);
--     Tareas(5):=(2,10,24,0,0.0,0.0);
--     Tareas(6):=(2,10,24,0,0.0,0.0);
--     Tareas(7):=(20,10,24,0,0.0,0.0);

   Put_line ("Programa que calcula si las siguientes tareas son planificables");
   -- imprimir parametros temporales de tareas
   for i in 1..Num_tasks loop
      put_line("############################################");
      put_line("Tarea " &Integer'Image(i));
      put_line("El peor tiempo de computo de la tarea es: " &Integer'Image(Tareas(i).wcet));
      put_line("El plazo de la tarea es: " &Integer'Image(Tareas(i).deadline));
      put_line("El periodo de la tarea es: " &Integer'Image(Tareas(i).period));
      new_line;
   end loop;

   put_line("Pulsa una tecla para comenzar el análisis de planificabilidad DM");
   get(c);

   if test_inicial = TRUE then
      put_line("Todos los plazos coinciden con los periodos.");
      if test_factor_utilizacion(float(Num_Tasks)) = TRUE then
         put_line("El sistema es planificable según el test del factor utilización");
      else
         put_line("El sistema no es planificable según el test del factor utilización");
         if test_tiempo_respuesta = TRUE then
            put_line("El sistema es planificable según el test de tiempo de respuesta");
         else
            put_line("El sistema no es planificable");
         end if;
      end if;
   else
      put_line("No todos los plazos coinciden con los periodos");
      if test_tiempo_respuesta = TRUE then
         put_line("El sistema es planificable según el test de tiempo de respuesta");
      else
         put_line("El sistema no es planificable");
      end if;
   end if;

end Main;

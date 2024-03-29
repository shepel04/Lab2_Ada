with Ada.Text_IO; use Ada.Text_IO;
with Ada.Calendar; use Ada.Calendar;

procedure Main is

   array_size : constant Integer := 200000;
   thread_num : constant Integer := 4;
   index_random: Integer := 4444;
   indexMinAll: Integer := 0;
   arr : array(0..array_size) of Integer;

   procedure Init_Arr is
   begin
      for i in 1..array_size loop
         arr(i) := i;
      end loop;
      arr(index_random):=arr(index_random)*(-1);
   end Init_Arr;

   function find_min(start_index, finish_index : in Integer) return Integer is
   min : Integer := arr(start_index);
   indexMin : Integer := start_index;
   found : Boolean := False;
begin
   for i in start_index..finish_index loop
      if min > arr(i) then
         min := arr(i);
         indexMin := i;
         if not found then
            Put_Line("Minimum value found at index: " & indexMin'Img);
            found := True;
         end if;
      end if;
   end loop;
   return min;
end find_min;

   task type main_thread is
      entry start(start_index, finish_index : in Integer);
   end main_thread;

   protected part_manager is
      procedure set_find_min(min, index : in Integer);
      entry get_min(min2, index : out Integer);
   private
      tasks_count : Integer := 0;
      min_value : Integer := arr(1);
      min_index : Integer := 1;
   end part_manager;

   protected body part_manager is
      procedure set_find_min(min, index : in Integer) is
      begin
         if min_value > min then
            min_value := min;
            min_index := index;
         end if;
         tasks_count := tasks_count + 1;
      end set_find_min;
      entry get_min(min2, index : out Integer) when tasks_count = thread_num is
      begin
         min2 := min_value;
         index := min_index;
      end get_min;
   end part_manager;

   task body main_thread is
   min : Integer := 0;
   indexMin : Integer := 0;
   start_index, finish_index : Integer;
begin
   accept start(start_index, finish_index : in Integer) do
      main_thread.start_index := start_index;
      main_thread.finish_index := finish_index;
   end start;
   min := find_min(start_index  => start_index,
                   finish_index => finish_index);
   indexMin := start_index;  -- Set indexMin to start_index
   part_manager.set_find_min(min, indexMin);
end main_thread;


   function parallel_sum return Integer is
      min : Integer := 0;
      index : Integer := 0;
      thread : array(1..thread_num) of main_thread;
      len : Integer := array_size/thread_num;
   begin
      for i in 1..thread_num-1 loop
         thread(i).start((i-1)*len,i*len);

      end loop;
      thread(thread_num).start(len*(thread_num-1), array_size);
      part_manager.get_min(min, index);

      return min;
   end parallel_sum;

   time : Ada.Calendar.Time := Clock;
   finish_time : Duration;
   result : Integer;
begin
   Init_Arr;
   time := Clock;
   result := find_min(0, array_size);
   finish_time := Clock - time;
   Put_Line(result'Img & " one thread time: " & finish_time'Img & " seconds");

   time := Clock;
   result := parallel_sum;
   finish_time := Clock - time;
   Put_Line(result'Img & " more thread time: " & finish_time'Img & " seconds");
end Main;

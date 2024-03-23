with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Calendar; use Ada.Calendar;

procedure Main is

   array_size : constant Long_Long_Integer := 200000;
   thread_num : constant Long_Long_Integer := 4;
   index_random: Long_Long_Integer := 4444;
   arr : array(0..array_size) of Long_Long_Integer;

   procedure Init_Arr is
   begin
      for i in 1..array_size loop
         arr(i) := i;
      end loop;
      arr(index_random):=arr(index_random)*(-1);
   end Init_Arr;

   function find_min(start_index, finish_index : in Long_Long_Integer) return Long_Long_Integer is
      min : Long_Long_Integer := arr(start_index);
   begin
      for i in start_index..finish_index loop
         if(min>arr(i)) then
            min:=arr(i);
         end if;
      end loop;
      return min;
   end find_min;

   task type main_thread is
      entry start(start_index, finish_index : in Long_Long_Integer);
   end main_thread;

   protected part_manager is
      procedure set_find_min(min : in Long_Long_Integer);
      entry get_min(min2 : out Long_Long_Integer);
   private
      tasks_count : Long_Long_Integer := 0;
      min1 : Long_Long_Integer := arr(1);
   end part_manager;

   protected body part_manager is
      procedure set_find_min(min : in Long_Long_Integer) is
      begin
         if (min1>min) then
            min1 :=min;
         end if;
         tasks_count := tasks_count + 1;
      end set_find_min;
      entry get_min(min2 : out Long_Long_Integer) when tasks_count = thread_num is
      begin
         min2 := min1;
      end get_min;


   end part_manager;

   task body main_thread is
      min : Long_Long_Integer := 0;
      start_index, finish_index : Long_Long_Integer;
   begin
      accept start(start_index, finish_index : in Long_Long_Integer) do
         main_thread.start_index := start_index;
         main_thread.finish_index := finish_index;
      end start;
      min := find_min(start_index  => start_index,
                      finish_index => finish_index);
      part_manager.set_find_min(min);
   end main_thread;

   function parallel_sum return Long_Long_Integer is
      min : Long_Long_Integer := 0;
      thread : array(1..thread_num) of main_thread;
      len : Long_Long_Integer:= array_size/thread_num;
   begin
      for i in  1..thread_num-1 loop
         thread(i).start((i-1)*len,i*len);

      end loop;
      thread(thread_num).start(len*(thread_num-1), array_size);
      part_manager.get_min(min);
      return min;
   end parallel_sum;
   time :Ada.Calendar.Time := Clock;
   finish_time :Duration;
   rezult:Long_Long_Integer;
begin
   Init_Arr;
   time:=Clock;
   rezult:=find_min(0, array_size);
   finish_time:=Clock-time;
   Put_Line(rezult'img &" one thread time: " & finish_time'img & " seconds");
   time:=Clock;
   rezult:=parallel_sum;
   finish_time:=Clock-time;
   Put_Line(rezult'img &" more thread time: " & finish_time'img & " seconds");
end Main;


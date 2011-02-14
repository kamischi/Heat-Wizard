       if Volt < VoltageRangeLimits[0] then
       begin
         ThermoElementError := ValueTooLow;
         exit (0);
       end;
       if Volt > VoltageRangeLimits[high(VoltageRangeLimits)] then
       begin
         ThermoElementError := ValueTooHigh;
         exit (0);
       end;

       range := 0;
       while Volt > VoltageRangeLimits[range] do
         inc(range);
       
       Volt2Temp := d[range][high(d[range])];
       for i := high(d[range])-1 downto 0 do
         Volt2Temp := Volt2Temp * Volt + d[range][i];

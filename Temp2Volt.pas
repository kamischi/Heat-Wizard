       if Temp < TemperatureRangeLimits[0] then
       begin
         ThermoElementError := ValueTooLow;
         exit (0);
       end;
       if Temp > TemperatureRangeLimits[high(TemperatureRangeLimits)] then
       begin
         ThermoElementError := ValueTooHigh;
         exit (0);
       end;

       range := 0;
       while Temp > TemperatureRangeLimits[range] do
         inc(range);
       
       Temp2Volt := c[range][high(c[range])];
       for i := high(c[range])-1 downto 0 do
         Temp2Volt := Temp2Volt * Temp + c[range][i];


       if Temp < TemperatureRangeLimits[0] then
       begin
         ThermoElementError := ValueTooLow;
         // with fpc > 2.4.2 this can probably be changed to $ieeeerrors
         {$rangechecks off} {$overflowchecks off}
         exit (NaN);
         {$rangechecks on}  {$overflowchecks on}
       end;
       if Temp > TemperatureRangeLimits[high(TemperatureRangeLimits)] then
       begin
         ThermoElementError := ValueTooHigh;
         {$rangechecks off} {$overflowchecks off}
         exit (NaN);
         {$rangechecks on}  {$overflowchecks on}
       end;

       range := 0;
       while Temp > TemperatureRangeLimits[range] do
         inc(range);
       
       Temp2Volt := c[range][high(c[range])];
       for i := high(c[range])-1 downto 0 do
         Temp2Volt := Temp2Volt * Temp + c[range][i];


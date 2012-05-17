function machineName0 = get_eml_metadata_machine_name(machineName)

%   Copyright 2008 The MathWorks, Inc.

machineName0 = '';
for i = 1:numel(machineName)
   if (machineName(i) >= '0' && machineName(i) <= '9') || ...
      (machineName(i) >= 'a' && machineName(i) <= 'z') || ...
      (machineName(i) >= 'A' && machineName(i) <= 'Z') || ...
       machineName(i) == '_'
        machineName0 = [machineName0 machineName(i)];
   else
        machineName0 = [machineName0 '_' num2str(int32(machineName(i)))];
   end
end

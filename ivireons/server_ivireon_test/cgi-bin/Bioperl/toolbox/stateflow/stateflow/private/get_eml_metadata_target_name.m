function targetName0 = get_eml_metadata_target_name(targetName)

%   Copyright 2008-2010 The MathWorks, Inc.

if strcmp(targetName, 'sfun') || ...
   strcmp(targetName, 'rtw')
   targetName0 = targetName; % User friendly name
else
   targetName0 = 'T';
   for i = 1:numel(targetName)
       if (targetName(i) >= '0' && targetName(i) <= '9') || ...
          (targetName(i) >= 'a' && targetName(i) <= 'z') || ...
          (targetName(i) >= 'A' && targetName(i) <= 'Z')
            targetName0 = [targetName0 targetName(i)];
       else
            targetName0 = [targetName0 '_' num2str(int32(targetName(i)))];
       end
   end
end



function ConvertConfig(this,cfg)
% Converts ActiveConfigSet into SimOptionForm

%   $Revision: 1.1.6.1 $ $Date: 2004/08/01 00:10:06 $
%   Copyright 1986-2004 The MathWorks, Inc.

if ~isa(cfg,'Simulink.ConfigSet')
   %Don't do anything as have wrong input type
   return
end

%Transfer values from cfg structure to SimOptionForm on field by field
%basis
Fields = fieldnames(this);
for iFields = 1:numel(Fields)
   %Find cfg component that contains the required field
   found = false;
   iComp = 1;
   while ~found & (iComp <= numel(cfg.components))
      if any(strcmp(fieldnames(cfg.components(iComp)),Fields{iFields}))
         found = true;
         %Copy the field data
         this.(Fields{iFields}) = cfg.components(iComp).(Fields{iFields});
      end
      iComp = iComp+1;
   end
end
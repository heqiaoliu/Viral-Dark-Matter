function machineId = sf_force_open_machine(machineName,loadInvisible)
%MAHCINEID = SF_FORCE_OPEN_SELECTION(MACHINENAME) 
% If the machineName is already open and in data dictionary
% then the machineId is returned. If not, it is opened and 
% in case of libraries, the data-dictionary load is forced
% by locking and unlocking the model, and the resultant
% machineId is returned. As of now, this is
% used by toolbox/rtw/sf_rtw.m, and private/autobuild.m
% 
%   Vijaya Raghavan
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.9.2.3 $  $Date: 2008/12/01 08:07:17 $

if(nargin<2)
   loadInvisible = 1;
end
if(isnumeric(machineName))
    machineName = get_param(machineName,'name');
end
machineId = sf('find',sf('MachinesOf'),'machine.name',machineName);
if(isempty(machineId))
   
   if(loadInvisible)
      global SF_LOAD_ALL_CHARTS_CLOSED %#ok<TLEV,NUSED>
   end
   try
     feval(machineName,[],[],[],'load');
   
     if(strcmp(get_param(machineName,'BlockDiagramType'),'library'))         
       set_param(machineName,'lock','off');
       set_param(machineName,'lock','on');
     end
   catch ME
     if(loadInvisible)
       clear global SF_LOAD_ALL_CHARTS_CLOSED
     end
     rethrow(ME);
   end
   if(loadInvisible)
      clear global SF_LOAD_ALL_CHARTS_CLOSED
   end

   machineId = sf('find','all','machine.name',machineName);
end


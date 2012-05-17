function [sysList,Extras,Options] = parseRespFcnInputs(InputList,InputNames)
% Parser for input argument list to response plot function.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:49:19 $
Options = [];
Extras = cell(1,0);
% Data = system object, Name = system name, Style = plot style
sysList = struct('System',cell(0,1),'Name',[],'Style',[]);

% Scan input list
ni = nargin;
nsys = 0;
for ct=1:length(InputList)
   arg = InputList{ct};
   if isa(arg,'DynamicSystem')
      nsys = nsys+1;   
      sysList(nsys).System = arg;  
      if isempty(arg.Name) && ni>1
         sysList(nsys).Name = InputNames{ct};
      else
         sysList(nsys).Name = arg.Name;
      end
   elseif isa(arg,'plotopts.PlotOptions')
      Options = arg;
   elseif ischar(arg) && ~any(strcmpi(arg,{'inv','zoh','foh'}))
      % Note: support step(sys1,sys2,'r',sys3,sys4,'g--')
      if nsys==0 || ~isempty(sysList(nsys).Style)
         % Plot style comes first or is repeated
         ctrlMsgUtils.error('Control:analysis:rfinputs01')
      end
      % Validate plot style
      [~,~,~,msg] = colstyle(arg);
      if ~isempty(msg)
          ctrlMsgUtils.error('Control:analysis:rfinputs02',arg)
      end
      sysList(nsys).Style = arg;
   else
      Extras = [Extras {arg}]; %#ok<*AGROW>
   end
end


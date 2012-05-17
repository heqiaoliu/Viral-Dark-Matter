function varargout = emlnew(machineName)
% EMLNEW 
% Creates a new Simulink model containing a single Embedded MATLAB Function
% block.

% Copyright 2002-2004 The MathWorks, Inc.


error(nargchk(0,1,nargin));
error(nargchk(0,2,nargout));

% If a name was passed in, use it. 
if nargin==1,
	if ~ischar(machineName), warning('Stateflow:UnexpectedError','Bad input to emlnew command!'); return; end;
	h = new_system(machineName);
else
	h = new_system;
end
modelName = get_param(h,'name');
newMachineH = sf('new', 'machine', '.name', modelName, '.simulinkModel', h);

if(isempty(sf('find',sf('MachinesOf'),'machine.name','emllib')))
   eml_lib([],[],[],'load');
end
open_system(h);
name = get_param(h,'Name');
emlLong = ['Embedded' 10 'MATLAB Function'];
sfBlk = [name,'/', emlLong ];
add_block(['eml_lib/', emlLong], sfBlk);

if nargout>0
   varargout{1} = h;
   if(nargout>1)
      varargout{2} = newMachineH;
   end
end



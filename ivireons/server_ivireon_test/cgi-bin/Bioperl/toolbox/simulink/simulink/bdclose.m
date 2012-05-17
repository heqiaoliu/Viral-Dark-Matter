function bdclose(sys)
%BDCLOSE Close any or all Simulink systems except those that are being
%   debugged or have been put into a compiled state via the 'compile'
%   option of the model command.
%
%   BDCLOSE closes the current system window (except if it's in a debug
%   or compiled state) without confirmation. Any changes made to the
%   system  since it was last saved are lost.
%
%   BDCLOSE('SYS') closes the specified system window.
%
%   BDCLOSE('all') closes all system windows.
%
%   Example:
%
%       bdclose('vdp')
%
%   closes the vdp system.
%
%   See also CLOSE_SYSTEM, OPEN_SYSTEM, NEW_SYSTEM, SAVE_SYSTEM.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.28.2.7 $


%
% no args, close the current system
%

if nargin == 0,
  sys = gcs;
elseif nargin > 1
  DAStudio.error('Simulink:utility:invalidNumInputs');
end

allsys = {};
if ischar(sys)
  %
  % The input argument is a string. It is either the name of a
  % system or the specifier 'all'
  %
  if strcmpi(sys,'all')
    allsys = find_system('SearchDepth',0);
  else
    allsys = {sys};
  end
elseif iscell(sys)
  %
  % Check that the cell array is an array of strings
  %
  for i = 1:length(sys)
    thisys = sys{i};
    if ~ischar(thisys)
      DAStudio.error('Simulink:utility:inputNonSystem');
    end
  end
  allsys = sys;
elseif isa(sys,'double')
  if nnz(sys == 0)
    DAStudio.error('Simulink:utility:invalidHandle');
  end
  allsys = sys;
else
  DAStudio.error('Simulink:utility:invalidArgType');
end

if ~isempty(allsys)
  %
  % At this point, we want to stop any valid models which are
  % being closed from simulating
  %
  allmdls = [];
  try
    allmdls = find_system(allsys, 'SearchDepth', 0, 'Type', ...
			  'block_diagram');
  catch  %#ok<CTCH>
  end
  
  if ~isempty(allmdls)
    %
    % Make sure that simulation is stopped for all block diagrams
    %
    allbds = find_system(allmdls, 'SearchDepth', 0, ...
			 'BlockDiagramType','model');
    
    for i=1:length(allbds)
        if iscell(allbds)
            slobj = allbds{i};
        else
            slobj = allbds(i);
        end

        if strcmp(get_param(slobj, 'SimulationStatus'), 'external')
            for nSys=1:length(allsys)
                if strcmp(allsys{nSys}, get_param(slobj,'Name'))
                    % Model will close automatically after disconnect
                    allsys{nSys} = '';
                end
            end
            % If extmode, disconnect and leave target running
            % If raccel, stop target
            set_param(slobj,'ShutDownForModelClose','off');
        else
            set_param(slobj,'SimulationCommand','Stop');
        end
    end
  end
  
  try
    close_system(allsys,0);
  catch e
    rethrow(e)
  end
end
return;

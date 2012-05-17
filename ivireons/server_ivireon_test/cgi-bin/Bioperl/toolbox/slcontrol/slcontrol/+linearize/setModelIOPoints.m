function [oldio,iovalid] = setModelIOPoints(models,ios,varargin)
% SETLINIO Utility method to set the linearization IOs on a model.
%
 
% Author(s): John W. Glass 28-Jan-2008
% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:53:39 $

% The silent flag is use to silently eliminate IOs that are no longer part
% of a Simulink model when loading a saved GUI session.
if (nargin == 3) && strcmp(varargin{1},'silent')
    silent = true;
else
    silent = false;
end

%Check that the passed ios are valid
[ios, ioinvalid] = linearize.checkModelIOPoints(models,ios);
if ~isempty(ioinvalid) && ~silent
   ctrlMsgUtils.error('Slcontrol:linearize:InvalidIO',ioinvalid(1).PortNumber,ioinvalid(1).Block)
end
iovalid = ios;

% Get the old IO settings
oldio = linearize.getModelIOPoints(models);

% Remove the inactive ios
ios(strcmp(get(ios,'Active'),'off')) = [];

% Remove the oldios that are in ios
% Concatenate the names with the ports
io_str = cell(size(ios));
for ct = length(ios):-1:1
    if strcmp(ios(ct).Active,'on')
        io_str{ct} = sprintf('%s-%d',ios(ct).Block,ios(ct).PortNumber);
    else
        io_str{ct} = '';
    end
end

% Concatenate the names with the ports
oldio_str = cell(size(oldio));
for ct = length(oldio):-1:1
    oldio_str{ct} = sprintf('%s-%d',oldio(ct).Block,oldio(ct).PortNumber); 
end

% Find the intersection
[~, ia] = intersect(oldio_str,io_str);
oldio_clear = oldio;
oldio_clear(ia) = [];

% Reset the diagram ios to be off
for ct = 1:length(oldio_clear)
    p = get_param(oldio_clear(ct).Block,'PortHandles');
    op = p.Outport(oldio_clear(ct).PortNumber);
    set_param(op,'LinearAnalysisInput','off');
    set_param(op,'LinearAnalysisOutput','off');
    set_param(op,'LinearAnalysisLinearizeOrder','off');
    set_param(op,'LinearAnalysisOpenLoop','off');
end

% Set the new properties
try
    for ct = 1:length(ios)
        % Get the block port handles
        p = get_param(ios(ct).Block,'PortHandles');
        
        % Get port handle
        port = p.Outport(ios(ct).PortNumber);
        
        if strcmpi(ios(ct).Type,'in');
            props = {'on';'off';'off'};
        elseif strcmpi(ios(ct).Type,'out');
            props = {'off';'on';'off'};
        elseif strcmpi(ios(ct).Type,'inout');
            props = {'on';'on';'off'};
        elseif strcmpi(ios(ct).Type,'outin');
            props = {'on';'on';'on'};
        elseif strcmpi(ios(ct).Type,'none');
            props = {'off';'off';'off'};
        end
        
        % Set the properties
        local_set_param(port,'LinearAnalysisInput',props{1});
        local_set_param(port,'LinearAnalysisOutput',props{2});
        local_set_param(port,'LinearAnalysisLinearizeOrder',props{3});
        local_set_param(port,'LinearAnalysisOpenLoop',ios(ct).OpenLoop);
    end
catch Ex
    linearize.setModelIOPoints(models,oldio);
    rethrow(Ex);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_set_param(port,property,value)

if ~strcmp(get_param(port,property),value)
    set_param(port,property,value);
end
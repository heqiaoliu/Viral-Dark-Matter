function [oldio,iovalid] = setlinio(this,models,ios,varargin)
% SETLINIO Utility method to set the linearization IOs on a model.
%
 
% Author(s): John W. Glass 28-Jan-2008
%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/04/11 20:40:57 $

% The silent flag is use to silently eliminate IOs that are no longer part
% of a Simulink model when loading a saved GUI session.
if (nargin == 4) && strcmp(varargin{1},'silent')
    silent = true;
else
    silent = false;
end

% Make sure that all of the ios are valid
for ct = numel(ios):-1:1
    % Make sure that the block and ports exist
    try
        ph = get_param(ios(ct).Block,'PortHandles');
    catch Ex %#ok<NASGU>
        if ~silent
            ctrlMsgUtils.error('Slcontrol:linearize:InvalidIO',ios(ct).Port,ios(ct).Block)
        else
            ios(ct) = [];
            continue
        end
    end
    if numel(ph.Outport) < ios(ct).Port
        if ~silent
            ctrlMsgUtils.error('Slcontrol:linearize:InvalidIO',ios(ct).Port,ios(ct).Block)
        else
            ios(ct) = [];
        end
    end
    % Make sure that the IO is in the top model or in one of the model
    % references
    if ~strcmp(bdroot(ios(ct).Block),models)
        if ~silent
            ctrlMsgUtils.error('Slcontrol:linearize:InvalidIO',ios(ct).Port,ios(ct).Block)
        else
            ios(ct) = [];
        end
    end
end
iovalid = ios;

% Get the old IO settings
oldio = getlinio(linutil,models);

% Remove the inactive ios
ios(strcmp(get(ios,'Active'),'off')) = [];

% Remove the oldios that are in ios
% Concatenate the names with the ports
io_str = cell(size(ios));
for ct = length(ios):-1:1
    if strcmp(ios(ct).Active,'on')
        io_str{ct} = sprintf('%s-%d',ios(ct).Block,ios(ct).Port);
    else
        io_str{ct} = '';
    end
end

% Concatenate the names with the ports
oldio_str = cell(size(oldio));
for ct = length(oldio):-1:1
    oldio_str{ct} = sprintf('%s-%d',oldio(ct).Block,oldio(ct).Port); 
end

% Find the intesection
[io_int, ia] = intersect(oldio_str,io_str);
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
    setlinio(this,models,oldio);
    rethrow(Ex);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_set_param(port,property,value)

if ~strcmp(get_param(port,property),value)
    set_param(port,property,value);
end

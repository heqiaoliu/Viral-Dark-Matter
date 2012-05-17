function bool = hasNonDoubleInportOutport(this,model)
% HASNONDOUBLEINPORTOUTPORT returns true if the model has a root-level inport/outport
% that compiles to a non-double data type
 
% Author(s): Erman Korkut 29-May-2008
% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:34:36 $

bool = false;

% Obtain the list of root-level inports and outports
inblocks = find_system(model,'SearchDepth',1,'BlockType','Inport');
outblocks = find_system(model,'SearchDepth',1,'BlockType','Outport');

% Loop through outports
for ct = 1:length(outblocks)
    ph = get_param(outblocks{ct},'PortHandles');
    % Error if non-double
    if ~strcmp(get_param(ph.Inport,'CompiledPortDataType'),'double')
        bool = true;
        return;
    end
end

% Loop through inports
for ct = 1:length(inblocks)
    ph = get_param(inblocks{ct},'PortHandles');
    % Error if non-double
    if ~strcmp(get_param(ph.Outport,'CompiledPortDataType'),'double')
        bool = true;
        return;
    end
end
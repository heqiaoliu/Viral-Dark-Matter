function [NewInputs,ind_old_del] = findNewInputs(this,Check)
% FINDNEWINPUTS  Find any new input ports that are not in the operating
% point/specification object
%
 
% Author(s): John W. Glass 10-Dec-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/01/15 18:57:06 $

% Find the inports to the model
NewInputs = find_system(this.Model,'SearchDepth',1,'BlockType','Inport');

% Ignore non-double or complex input port data types
invalid_datatype = false;
for ct = numel(NewInputs):-1:1
    PortDataTypes = get_param(NewInputs{ct},'CompiledPortDataTypes');
    ComplexSignals = get_param(NewInputs{ct},'CompiledPortComplexSignals');
    if ~strcmp(PortDataTypes.Outport{1},'double') || ComplexSignals.Outport
        invalid_datatype = true;
        break
    end
end

if invalid_datatype
    NewInputs = {};
    if ~Check
        ctrlMsgUtils.warning('SLControllib:opcond:ModelHasNonDoubleRootPortInputDataTypes',this.model)
    end
end

ind_old_del = true(numel(this.inputs),1);
if isempty(this.inputs)
    return
end

% Check to see in output constraints need to be added for changes in
% the number of outports or portwidths.
% Get the current block names and port numbers
old_Blocks = get(this.inputs,{'Block'});
ind_new_del = false(numel(NewInputs),1);
for ct = numel(NewInputs):-1:1
    ind_old = find(strcmp(NewInputs{ct},old_Blocks));
    if ~isempty(ind_old)
        Ports = get_param(NewInputs{ct},'PortHandles');
        % Get the port width
        PortWidth = get_param(Ports.Outport(1),'CompiledPortWidth');
        if (PortWidth == this.inputs(ind_old).PortWidth)
            ind_new_del(ct) = true;
            ind_old_del(ind_old) = false;
        end
    end
end
NewInputs(ind_new_del) = [];
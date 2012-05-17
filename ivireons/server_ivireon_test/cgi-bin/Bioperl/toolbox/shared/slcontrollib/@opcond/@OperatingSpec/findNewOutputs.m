function [NewOut,ind_old_del] = findNewOutputs(this)
% FINDNEWOUTPUTS 
%
 
% Author(s): John W. Glass 11-Dec-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/01/15 18:57:11 $

% Initialize the data structure for new output ports
NewOut = struct('Block',{},'PortNumber',{});

% Find the outports to the model
RootOutports = find_system(this.Model,'SearchDepth',1,'BlockType','Outport');

% Find trimmed signals in the model
TrimOut = find_system(this.Model,'findall','on','type','port',...
                            'LinearAnalysisTrim','on');

if ~isempty(RootOutports)
    NewOut = [NewOut; struct('Block',RootOutports,'PortNumber',NaN)];
end

if ~isempty(TrimOut)
    NewOut = [NewOut;...
              struct('Block',get_param(TrimOut,'Parent'),...
               'PortNumber',get_param(TrimOut,'PortNumber'))];
end

ind_old_del = false(numel(this.outputs),1);
portnum = get(this.outputs,{'PortNumber'});
ind_old_del(isnan([portnum{:}])) = true;
if isempty(this.outputs)
    return
end

% Check to see in output constraints need to be added for changes in
% the number of outports or portwidths.
% Get the current block names and port numbers
old_Blocks = get(this.outputs,{'Block'});
ind_new_del = false(numel(NewOut),1);

for ct = numel(NewOut):-1:1
    ind_old = find(strcmp(NewOut(ct).Block,old_Blocks));
    if ~isempty(ind_old)
        % Find the matching port number
        oldportscell = get(this.outputs(ind_old),{'PortNumber'});
        oldports = [oldportscell{:}];
        if isnan(NewOut(ct).PortNumber)
            ind_trimport = ind_old(isnan(oldports));
        else
            ind_trimport = ind_old(oldports == NewOut(ct).PortNumber);
        end
        if ~isempty(ind_trimport)
            Ports = get_param(NewOut(ct).Block,'PortHandles');
            % Get the port width
            if isnan(NewOut(ct).PortNumber);
                PortWidth = get_param(Ports.Inport,'CompiledPortWidth');
            else
                PortWidth = get_param(Ports.Outport(NewOut(ct).PortNumber),'CompiledPortWidth');
            end
            if (PortWidth == this.outputs(ind_trimport).PortWidth)
                ind_new_del(ct) = true;
                ind_old_del(ind_old) = false;
            elseif isnan(NewOut(ct).PortNumber)
                ind_new_del(ct) = false;
                ind_old_del(ind_old) = true;
            else
                ind_new_del(ct) = true;
                ind_old_del(ind_old) = false;
            end
        end
    end
end
NewOut(ind_new_del) = [];



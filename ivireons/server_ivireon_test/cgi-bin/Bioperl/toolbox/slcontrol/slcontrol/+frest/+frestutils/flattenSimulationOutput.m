function out = flattenSimulationOutput(simout,numsamps)
%

% FLATTENSIMULATIONOUTPUT Flatten the simulation output of FRESTIMATE such
% that each cell is a structure time and scalar data where time
% dimension is first. This utility is used by plotting commands such as
% simView and simCompare. 

%  Author(s): Erman Korkut 24-Mar-2009
%  Revised: 
%   Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/11/09 16:35:01 $

% Find out total number of output channels
numoutch = 0;
for ct = 1:size(simout,1)
    dims = size(simout{ct,1}.Data);
    if LocalIsTimeFirst(dims,numsamps)
        numoutch = numoutch + prod(dims(2:end));
    else
        numoutch = numoutch + prod(dims(1:end-1));
    end
end
% Flatten the outputs
numinch = size(simout,2);
out = cell(numoutch,numinch);
for ctin = 1:numinch
    out_ind = 1;
    for ctout = 1:size(simout,1)
        data = simout{ctout,ctin}.Data;
        time = simout{ctout,ctin}.Time;
        dims = size(data);
        numch = LocalFindNumChannels(dims,numsamps);
        % Make it time first at this point if it is not time first
        if ~LocalIsTimeFirst(dims,numsamps)
            data = shiftdim(data,numel(dims)-1);
        end
        if numch == 1
            % No flattening necessary for this row, just write to all
            % columns
            out{out_ind,ctin}.Time = time;
            out{out_ind,ctin}.Data = data;
            out_ind = out_ind + 1;
        else
            % This row is not scalar, flatten
            for ctch = 1:numch
                % Modify data to have only this channel
                out{out_ind,ctin}.Time = time;
                out{out_ind,ctin}.Data = data(:,ctch);
                out_ind = out_ind + 1;
            end
        end
    end
end
function bool = LocalIsTimeFirst(dims,numsamps)
bool = (dims(1) == numsamps);
function numch = LocalFindNumChannels(dims,numsamps)
if LocalIsTimeFirst(dims,numsamps)
    numch = prod(dims(2:end));
else
    numch = prod(dims(1:end-1));
end


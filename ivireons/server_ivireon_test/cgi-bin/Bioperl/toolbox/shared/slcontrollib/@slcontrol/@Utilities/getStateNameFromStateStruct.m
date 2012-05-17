function [xstruct,x_str,ncstates,indcstates,x_statename] = getStateNameFromStateStruct(this,xstruct)
% GETSTATENAMEFROMSTATESTRUCT  Get a cell array of the states in a state
% structure in the order that the structure is specified.  Also return the
% number of continuous states, the indices of the continuous states.
%
 
% Author(s): John W. Glass 08-Mar-2005
%   Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/04/28 03:26:08 $

% Initialize vectors
ncstates = 0;
indcstates = [];
x_str = {};
x_statename = {};

if isempty(xstruct)
    return;
end

% Compute the number of continuous states and construct the list of all of
% the state names.
for ct = 1:length(xstruct.signals)
    if strcmp(xstruct.signals(ct).label,'CSTATE')
        ncstates = ncstates + xstruct.signals(ct).dimensions;
        indcstates = [indcstates;ct];
    end
    for ct2 = 1:xstruct.signals(ct).dimensions
        x_str{end+1,1} = xstruct.signals(ct).blockName;
        x_statename{end+1,1} = xstruct.signals(ct).stateName;
    end
end

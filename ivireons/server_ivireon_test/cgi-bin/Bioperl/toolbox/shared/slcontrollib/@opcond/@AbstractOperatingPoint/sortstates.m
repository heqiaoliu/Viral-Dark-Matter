function sortstates(this,statecell,varargin)
% SORTSTATES Sorts the states of an operating point object given a cell
% array of state names.
%
% SORTSTATES(OP,STATECELL) sorts the states of the operating point OP
% object.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/10/15 23:28:15 $

if nargin == 3
    erroronmismatch = varargin{1};
else
    erroronmismatch = true;
end

% Sort the states first get the states in the operating point
OpStates = cell(length(this.States),1);
for ct = 1:length(this.States)
    if isempty(this.States(ct).StateName)
        OpStates{ct} = this.States(ct).Block;
    else
        OpStates{ct} = this.States(ct).StateName;
    end
end

% Loop over the state objects
ind = [];
state_ctr = 1:numel(OpStates);
for ct1 = 1:length(statecell)
    stateind = find(strcmp(statecell(ct1),OpStates));
    if isempty(stateind) && erroronmismatch
        ctrlMsgUtils.error('SLControllib:opcond:StateNotInOperatingPoint');
    end
    state_ctr(stateind) = 0;
    ind = [ind;stateind];
end

if (any(state_ctr) || (length(ind) ~= length(this.States))) && erroronmismatch
    ctrlMsgUtils.error('SLControllib:opcond:StateNotInOperatingPoint');
end

% Sort the operating point states
this.States = this.States([ind(:);find(state_ctr(:))]);
function this = StateSpec(varargin)
% STATESPEC  Constructor for the opcond.StateSpec object
%
 
% Author(s): John W. Glass 12-Nov-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:02:07 $

this = opcond.StateSpec;
if nargin == 0
    return
end

% Populate the state from the state struct
state_struct = varargin{1};
this.Block = state_struct.blockName;
this.StateName = state_struct.stateName;
this.SampleType = state_struct.label;
this.Ts = state_struct.sampleTime;

% Copy in the upper and lower bounds on the integrators if needed
if ~isempty(state_struct.Min) && ~isempty(state_struct.Max)
    this.Min = state_struct.Min;
    this.Max = state_struct.Max;
end
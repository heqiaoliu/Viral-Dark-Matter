function this = StatePoint(varargin)
% STATEPOINT  Constructor for the opcond.StatePoint object
%
 
% Author(s): John W. Glass 12-Nov-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/12/14 15:02:03 $

this = opcond.StatePoint;
if nargin == 0
    return
end

% Populate the state from the state struct
state_struct = varargin{1};
this.Block = state_struct.blockName;
this.StateName = state_struct.stateName;
this.SampleType = state_struct.label;
this.Ts = state_struct.sampleTime;
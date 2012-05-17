function this = StateSpec(stateID, subsName)
% STATESPEC Constructor
%
% This constructor takes a state identifier object and an optional subscripted
% name to create a STATESPEC object.
%
% h = modelpack.StateSpec(stateID, [subsName]);
%
% STATEID  a StateID object.
% SUBSNAME is the optional subscripted state name; otherwise set to empty.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:25:27 $

% Create object
this = modelpack.StateSpec;

% No argument constructor call.
ni = nargin;
if (ni == 0)
  return
end

% Set the default value to empty.
if (ni < 2 || isempty(subsName)), subsName = ''; end

% Set properties.
this.Version = 1.0;
this.setID(stateID);
this.setName(subsName);

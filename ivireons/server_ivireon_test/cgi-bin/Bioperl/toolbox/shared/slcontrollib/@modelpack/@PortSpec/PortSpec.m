function this = PortSpec(portID, subsName)
% PORTSPEC Constructor
%
% This constructor takes a port identifier object and an optional subscripted
% name to create a PORTSPEC object.
%
% h = modelpack.PortSpec(portID, [subsName]);
%
% PORTID   a PortID object.
% SUBSNAME is the optional subscripted port name; otherwise set to empty.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:23:48 $

% Create object
this = modelpack.PortSpec;

% No argument constructor call.
ni = nargin;
if (ni == 0)
  return
end

% Set the default value to empty.
if (ni < 2 || isempty(subsName)), subsName = ''; end

% Set properties.
this.Version = 1.0;
this.setID(portID);
this.setName(subsName);

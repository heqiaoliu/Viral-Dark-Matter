function hout = linearizationutil
% UTILITIES Static class for control related linearization utility methods.

% Author(s): John Glass
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2005/12/22 19:06:46 $

% Singleton object
persistent this

if isempty(this)
  % Create singleton class instance
  this = LinearizationObjects.linearizationutil;
end

% Language workaround.
hout = this;

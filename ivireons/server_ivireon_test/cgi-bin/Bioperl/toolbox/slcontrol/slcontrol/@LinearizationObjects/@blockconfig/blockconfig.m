function hout = blockconfig
% UTILITIES Static class for block configuration methods.

% Author(s): John Glass
% Revised: 
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2005/11/15 01:42:54 $

% Singleton object
persistent this

if isempty(this)
  % Create singleton class instance
  this = LinearizationObjects.blockconfig;
end

% Language workaround.
hout = this;

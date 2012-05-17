function applyOptions(this, Options)
% APPLYOPTIONS  Synchronizes plot options with those of characteristics
 
%  Author(s): Bora Eryilmaz
%  Copyright 1986-2007 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:19:30 $

cOpts = get(this(1), 'RiseTimeLimits');

% Set new preferences
if isfield(Options, 'RiseTimeLimits') && any(Options.RiseTimeLimits ~= cOpts)
  clear(this); % Vectorized clear
  set(this, 'RiseTimeLimits', Options.RiseTimeLimits);
end
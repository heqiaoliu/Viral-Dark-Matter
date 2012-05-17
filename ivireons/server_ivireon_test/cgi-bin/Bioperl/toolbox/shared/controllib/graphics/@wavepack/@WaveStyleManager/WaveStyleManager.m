function this = WaveStyleManager
%WAVESTYLEMANAGER  Constructor for @WaveStyleManager class.

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:27:13 $

% Create class instance
this = wavepack.WaveStyleManager;

% Compute a default set of style combinations
makestyles(this)
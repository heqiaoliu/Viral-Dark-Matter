function h = rleditor(LoopData,idxL)
%RLEDITOR  Constructor for the Root Locus Editor.

%   Authors: P. Gahinet
%   Revised: A. DiVergilio
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.39.4.3 $ $Date: 2010/03/26 17:22:51 $

% Create class instance
h = sisogui.rleditor;

% Initialize properties 
h.LoopData = LoopData;
h.EditedLoop = idxL;

% Root-locus specific properties
h.GridOptions = struct(...
    'GridLabelType','damping');
h.AxisEqual = 'off';

% Initialize compensator targets
h.initializeCompTarget;

h.UncertainBounds = sisogui.RootLocusUncertain(h);

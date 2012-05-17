function h = nicholseditor(LoopData,idxL)
%NICHOLSEDITOR  Constructor for the Nichols Plot Editor.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $ $Date: 2010/03/26 17:22:42 $

% Create class instance
h = sisogui.nicholseditor;

% Initialize properties 
h.LoopData = LoopData;
h.EditedLoop = idxL;

% REVISIT how should these be initialized?
% h.EditedBlock = LoopData.L(idxL).TunedFactors(1);
% h.GainTargetBlock = LoopData.L(idxL).TunedFactors(1);
h.initializeCompTarget;
h.UncertainBounds = sisogui.NicholsUncertain(h);
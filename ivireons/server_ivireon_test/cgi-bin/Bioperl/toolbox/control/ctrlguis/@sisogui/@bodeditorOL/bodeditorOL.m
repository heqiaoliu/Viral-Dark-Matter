function h = bodeditorOL(LoopData,idxL)
%BODEDITOROL  Constructor for the Open-Loop Bode Editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.8.4.3 $ $Date: 2010/03/26 17:22:34 $
h = sisogui.bodeditorOL;

% Initialize properties 
h.LoopData = LoopData;
h.EditedLoop = idxL;

% Initialize compensator targets
h.initializeCompTarget;

% Initialize uncertain bounds class
h.UncertainBounds = sisogui.BodeUncertain(h);
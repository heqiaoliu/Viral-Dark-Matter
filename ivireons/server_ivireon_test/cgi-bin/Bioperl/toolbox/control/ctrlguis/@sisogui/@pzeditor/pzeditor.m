function h = pzeditor(LoopData,Parent)
%PZEDITOR  Constructor for compensator pole/zero Editor.

%   Author(s): Karen Gondoly. 
%   Revised: P. Gahinet (OO implementation), C. Buhr, R Chen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2005/12/22 17:43:26 $

% Create class instance
h = sisogui.pzeditor;
h.PrecisionFormat = '%0.5g';
h.LoopData = LoopData;
h.Parent = Parent;

% Frequency Units
h.FrequencyUnits = Parent.Preferences.FrequencyUnits;

% Build 
h.buildeditor;

% Install listeners
h.addlisteners;


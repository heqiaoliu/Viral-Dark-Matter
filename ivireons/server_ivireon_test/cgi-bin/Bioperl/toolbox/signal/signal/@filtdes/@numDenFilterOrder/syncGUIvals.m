function syncGUIvals(h,arrayh)
%SYNCGUIVALS Sync values from frames.
%
%   Inputs:
%       h - handle to this object
%       arrayh - array of handles to frames


%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:48:41 $

% Get handle to frame
hf = find(arrayh,'Tag','siggui.numdenfilterorder');

% Store specs in object
set(h,'numOrder',evaluatevars(get(hf,'NumOrder')));
set(h,'denOrder',evaluatevars(get(hf,'DenOrder')));


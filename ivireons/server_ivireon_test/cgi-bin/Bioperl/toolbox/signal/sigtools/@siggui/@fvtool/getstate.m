function s = getstate(hFVT)
%GETSTATE Return the state of the Filter Visualization Tool

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2002/11/21 15:32:26 $

s.currentAnalysis = get(hFVT, 'Analysis');
s.OverlayedAnalysis  = get(hFVT, 'OVerlayedAnalysis');

% [EOF]

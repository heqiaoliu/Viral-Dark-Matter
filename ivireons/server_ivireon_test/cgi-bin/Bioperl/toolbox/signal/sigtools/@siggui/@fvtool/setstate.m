function setstate(hFVT, s)
%SETSTATE Set the state of the Filter Visualization Tool

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/11/21 15:31:58 $

if ~isfield(s, 'OverlayedAnalysis'),
    s.OverlayedAnalysis = '';
end

switch lower(s.currentAnalysis)
    case 'magresp'
        s.currentAnalysis = 'magnitude';
    case 'phaseresp'
        s.currentAnalysis = 'phase';
    case 'magnphaseresp'
        s.currentAnalysis = 'freq';
    case 'groupdelay'
        s.currentAnalysis = 'grpdelay';
    case 'impresp'
        s.currentAnalysis = 'impulse';
    case 'stepresp'
        s.currentAnalysis = 'step';
    case 'pzplot'
        s.currentAnalysis = 'polezero';
    case 'filtercoeffs'
        s.currentAnalysis = 'coefficients';
    case 'nlm'
        s.currentAnalysis = 'magestimate';
        s.OverlayedAnalysis  = 'noisepower';
end

set(hFVT, 'Analysis', s.currentAnalysis);
set(hFVT, 'OverlayedAnalysis', s.OverlayedAnalysis);

% [EOF]

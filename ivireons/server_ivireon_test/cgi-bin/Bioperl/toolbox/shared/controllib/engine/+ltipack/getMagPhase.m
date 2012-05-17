function [mag,ph] = getMagPhase(h,fdim,isPlotted)
%GETMAGPHASE  Extract mag and phase data from frequency response.
%
%   [MAG,PHASE] = GETMAGPHASE(H,FDIM) returns the magnitude and
%   phase (in radians) for the frequency response H. FDIM 
%   specifies the frequency dimension. 
% 
%   NOTE: Phase unwrapping assumes that H was evaluated on a 
%   monotonically increasing frequency grid.

%   Copyright 1986-2009 The MathWorks, Inc.
%  $Revision $  $Date: 2009/11/09 16:28:46 $
mag = abs(h);
ph = angle(h);
% Unwrap phase
% Note: Set phase to NaN when gain is infinite (erratic phase value 
% can confuse phase unwrapping)
idx = find(~isfinite(mag));
phInfNaN = ph(idx);
ph(idx) = NaN;
ph = unwrap(ph,[],fdim);
if ~isPlotted
   % Restore original values when phase array is an output
   ph(idx) = phInfNaN;
end


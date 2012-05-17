function eml_freqz_plot(s,b,a,h,w,varargin)
% A supporting function for an Embedded MATLAB Library Function

% Copyright 2009 The MathWorks, Inc.

phi = phasez(b,a,varargin{:});
data(:,:,1) = h;
data(:,:,2) = phi;
% Turn off "obsolete" warning before calling freqzplot.  When freqzplot gets
% obsoleted, it will move into signal/private, so eml_freqz_plot function
% will continue to work.
ws = warning('off','signal:freqzplot:obsoleteFunction');
freqzplot(data,w,s,'magphase');
warning(ws);

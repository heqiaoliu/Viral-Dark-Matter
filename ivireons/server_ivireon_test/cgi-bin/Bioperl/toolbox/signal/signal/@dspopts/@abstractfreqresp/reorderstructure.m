function s = reorderstructure(this,s) %#ok
%REORDERSTRUCTURE   

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:20:30 $

s = reorderstructure(s,'NFFT','NormalizedFrequency','Fs','SpectrumRange', 'CenterDC');

% [EOF]

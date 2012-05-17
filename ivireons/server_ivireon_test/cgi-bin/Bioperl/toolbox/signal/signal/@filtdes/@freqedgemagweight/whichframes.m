function fr = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:37:30 $

% Get frame needed by the freqspec
fr.constructor = 'fdadesignpanel.lpnorm';
fr.setops      = {};

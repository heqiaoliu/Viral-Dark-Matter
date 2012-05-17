function fr = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:10:36 $

% Get frame needed by the freqspec
fr.constructor = 'fdadesignpanel.iirgrpdelay';
fr.setops      = {};


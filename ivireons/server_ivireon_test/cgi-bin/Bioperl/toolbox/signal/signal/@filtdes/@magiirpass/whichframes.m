function fr = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:47:17 $


fr.constructor = 'fdadesignpanel.magpass';
fr.setops       = {'IRType','IIR'};


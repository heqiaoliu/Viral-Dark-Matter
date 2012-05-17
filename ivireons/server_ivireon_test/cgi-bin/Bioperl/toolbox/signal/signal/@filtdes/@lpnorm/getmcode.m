function v = getmcode(d, v)
%GETMCODE Get the value and format it for GENMCODE

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/10/04 18:12:51 $

% Get the mcode value with 17 digits of precision.
v = abstract_getmcode(d, v, 17);

% [EOF]

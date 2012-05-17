function [s, str] = createStruct(h)
%CREATESTRUCT Return the response types

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:21:08 $

str = 'iircombFilterTypes';

s(1).construct = 'filtdes.iirnotch';
s(1).tag       = 'Notching';

s(2).construct = 'filtdes.iirpeak';
s(2).tag       = 'Peaking';

% [EOF]

function [s, str] = createStruct(h)
%CREATESTRUCT Return the response types

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:21:25 $

str = 'iirnotchpeakFilterTypes';

s(1).construct = 'filtdes.iirnotchwfnotch';
s(1).tag       = 'Notching';

s(2).construct = 'filtdes.iirpeakwfpeak';
s(2).tag       = 'Peaking';

% [EOF]
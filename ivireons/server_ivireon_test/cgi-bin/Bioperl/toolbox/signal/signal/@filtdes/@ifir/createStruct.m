function [s,str] = createStruct(h)
%CREATESTRUCT Create a structure for each type.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/03/02 10:20:50 $

% Return a string for the name of the enumerated data type that will be created
str = 'ifirFilterTypes';

s(1).construct = 'filtdes.ifirlp';
s(1).tag = 'Lowpass';

s(2).construct = 'filtdes.ifirhp';
s(2).tag = 'Highpass';

% [EOF]

function b = thisgenmcode(d)
%THISGENMCODE Perform the IIR genmcode.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2009/12/28 04:35:44 $

% Frequencies Have been prenormalized (0 to 1)

% Call type specific design
b = genmcode(d.responseTypeSpecs, d);

% [EOF]
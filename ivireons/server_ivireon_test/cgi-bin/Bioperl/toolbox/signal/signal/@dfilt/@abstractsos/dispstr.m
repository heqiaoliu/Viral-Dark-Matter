function s = dispstr(Hd, varargin)
%DISPSTR Display string of coefficients.
%   DISPSTR(Hd) returns a string that can be used to display the coefficients
%   of discrete-time filter Hd.
%
%   See also DFILT.

%   Author: R. Losada
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.2.4.9 $  $Date: 2008/10/02 19:04:41 $

[num_str, den_str, sv_str] = dispstr(Hd.filterquantizer, Hd.privnum, ...
    Hd.privden, Hd.privscalevalues, varargin{:});

sos_str = [num_str repmat('  ', nsections(Hd), 1) den_str];

s = char({'SOS matrix:'
    sos_str
    ''
    'Scale Values:'
    sv_str});

% [EOF]

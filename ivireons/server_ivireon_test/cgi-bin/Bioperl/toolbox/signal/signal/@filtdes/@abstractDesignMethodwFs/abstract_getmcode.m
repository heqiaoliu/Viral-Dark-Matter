function v = abstract_getmcode(d, v, varargin)
%GETMCODE Get the value and format it for GENMCODE
%   GETMCODE(D, V) Get the value V and format it for GENMCODE.  V can be
%   the value or the property name containing the value.
%
%   GETMCODE(D, V, PREC) Format the value with PREC digits of precision.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/13 00:01:13 $

if ischar(v),
    v = get(d, v);
end

v = genmcodeutils('array2str', v, varargin{:});

% [EOF]

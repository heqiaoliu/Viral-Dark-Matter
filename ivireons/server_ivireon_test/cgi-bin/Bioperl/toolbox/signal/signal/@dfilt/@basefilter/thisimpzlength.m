function n = thisimpzlength(this, varargin)
%THISIMPZLENGTH   Dispatch and call the method.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/08/10 02:07:28 $

Hd = dispatch(this);
n = impzlength(Hd, varargin{:});

% [EOF]

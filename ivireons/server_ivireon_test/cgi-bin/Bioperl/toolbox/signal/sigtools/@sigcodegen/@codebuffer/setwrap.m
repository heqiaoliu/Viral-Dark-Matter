function wrap = setwrap(this, wrap)
%SETWRAP Set Function for the public wrap

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:46:09 $

str = this.string;
this.clear;
this.add(str);

% [EOF]

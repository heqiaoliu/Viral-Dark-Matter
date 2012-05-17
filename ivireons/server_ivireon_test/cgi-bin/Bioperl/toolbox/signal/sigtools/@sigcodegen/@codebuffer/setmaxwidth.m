function width = setmaxwidth(this, width)
%SETMAXWIDTH Set Function for the maximum width property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:46:08 $

str = this.string;
this.clear;
this.add(str);

% [EOF]

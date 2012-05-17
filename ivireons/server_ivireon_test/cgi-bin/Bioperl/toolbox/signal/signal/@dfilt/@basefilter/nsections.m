function nsecs = nsections(Hb)
%NSECTIONS Number of sections in a discrete filter.
%   NSECTIONS(Hb) returns the number of sections in a discrete
%   filter.
%
%   See also DFILT.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:53:01 $

nsecs = base_num(Hb, 'thisnsections');

% [EOF]

function proplist = reorderprops(this)
%REORDERPROPS   List of properties to reorder.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:00:35 $

proplist = {'Name','Data',getrangepropname(this)};

% [EOF]

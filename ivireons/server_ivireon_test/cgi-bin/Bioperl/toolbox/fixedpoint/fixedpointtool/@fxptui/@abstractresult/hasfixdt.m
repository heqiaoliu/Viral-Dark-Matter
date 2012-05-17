function b = hasfixdt(h)
%HASFIXDT   True if the object is fixdt.

%   Author(s): G. Taillefer
%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/17 21:49:34 $

b = ( ~isempty(strfind(h.SimDT, 'fixdt')) && ...
       isempty(strfind(h.SimDT, 'Scaled Double')) );

% [EOF]

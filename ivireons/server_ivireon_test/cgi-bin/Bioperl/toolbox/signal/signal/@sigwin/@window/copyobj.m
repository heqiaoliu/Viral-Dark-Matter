function hout = copyobj(hWIN)
%COPYOBJ 

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/04/13 00:16:53 $

hout = feval(str2func(class(hWIN)));
s = rmfield(get(hWIN), 'Name');
set(hout, s)

% [EOF]

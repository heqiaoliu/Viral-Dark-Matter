function s = saveobj(h)
%SAVEOBJ Save the object H

%   @modem\@mskdemod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:02:50 $

% Get the class fields
s = get(h);

% Get the objects class
s.class = class(h);

%-------------------------------------------------------------------------------

% [EOF]

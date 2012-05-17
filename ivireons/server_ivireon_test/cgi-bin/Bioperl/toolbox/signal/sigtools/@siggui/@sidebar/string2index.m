function index = string2index(hSB, string)
%STRING2INDEX Convert the string to an index

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:30:55 $

% This will be a private method

labels    = get(hSB, 'Labels');

% STRMATCH to find the correct index
index     = strmatch(string,labels,'exact');

% [EOF]

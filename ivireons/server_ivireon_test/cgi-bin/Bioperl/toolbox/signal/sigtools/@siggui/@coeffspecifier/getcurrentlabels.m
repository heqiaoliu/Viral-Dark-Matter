function lblStrs = getcurrentlabels(h)
%GETCURRENTLABELS

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:27:05 $

labels  = get(h,'Labels');
lblStrs = labels.(getshortstruct(h));

% [EOF]

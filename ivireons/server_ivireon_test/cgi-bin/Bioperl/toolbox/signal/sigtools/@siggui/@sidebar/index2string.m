function string = index2string(hSB, index)
%INDEX2STRING Convert the index to the matching string

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:19:26 $

% This will be a private method

labels    = get(hSB, 'Labels');

if index > length(labels)
    error(generatemsgid('IdxOutOfBound'),'Index is greater than the number of installed panels.');
else
    string = labels{index};
end

% [EOF]

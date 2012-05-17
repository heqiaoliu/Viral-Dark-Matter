function clear(h)
%CLEAR Removes all of the elements from the vector

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:46:09 $

% Clear out the vector.
set(h, 'Data', {});

sendchange(h, 'VectorCleared', []);

% [EOF]

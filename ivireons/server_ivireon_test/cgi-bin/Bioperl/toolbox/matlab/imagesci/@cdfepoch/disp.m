function disp(obj)
%DISP   DISP for CDFEPOCH object.

%   binky
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:07:54 $

% If obj is not scalar, then just display the size
s = size(obj);
if ~isequal(s,[1 1])
    disp(sprintf(['     [%dx%d cdfepoch]'], s(1), s(2)));
else
    disp(['     ' datestr(todatenum(obj),0)]);
end
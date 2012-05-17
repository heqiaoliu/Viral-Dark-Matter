function hObj = mcodebuffer(varargin)
%MCODEBUFFER Construct a MCODEBUFFER object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:27:59 $

hObj = sigcodegen.mcodebuffer;

if nargin > 0
    hObj.add(varargin);
end

% [EOF]

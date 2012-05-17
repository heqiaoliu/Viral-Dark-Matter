function hObj = pole(varargin)
%POLE Construct a pole object
%   POLE(NUM) Construct a pole object using the double NUM.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/01/27 19:09:55 $

hObj = sigaxes.pole;

construct_root(hObj, varargin{:});

% [EOF]

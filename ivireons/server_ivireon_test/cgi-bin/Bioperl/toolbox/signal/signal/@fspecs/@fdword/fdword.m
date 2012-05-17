function this = fdword(varargin)
%FDWORDER   Construct a FDWORDER object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:45:15 $

this = fspecs.fdword;
this.ResponseType = 'Fractional Delay with Filter Order';
this.FilterOrder = 3;
if nargin>0,
    this.FilterOrder = varargin{1};
end

% [EOF]

function zoom(this, varargin)
%ZOOM   Zoom 

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:21:29 $

error(nargchk(2,3,nargin,'struct'));

hFVT = getcomponent(this, 'fvtool');

zoom(hFVT, varargin{:});

% [EOF]

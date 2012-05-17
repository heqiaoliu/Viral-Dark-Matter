function abstractlayout_construct(this, h, varargin)
%ABSTRACTLAYOUT_CONSTRUCT   Abstract constructor

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:20:37 $

error(nargchk(2,inf,nargin,'struct'));

set(this, 'Panel', h);

if nargin > 2,
    set(this, varargin{:});
end

% [EOF]

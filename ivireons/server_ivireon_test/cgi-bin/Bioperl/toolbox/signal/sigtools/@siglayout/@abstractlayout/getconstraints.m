function constraints = getconstraints(this, varargin)
%GETCONSTRAINTS   Get the constraints.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:20:40 $

n = nfactors(this);

error(nargchk(1+n,1+n,nargin,'struct'));

hComponent = getcomponent(this, varargin{:});

constraints = getappdata(hComponent, getconstraintstag(this));

% [EOF]

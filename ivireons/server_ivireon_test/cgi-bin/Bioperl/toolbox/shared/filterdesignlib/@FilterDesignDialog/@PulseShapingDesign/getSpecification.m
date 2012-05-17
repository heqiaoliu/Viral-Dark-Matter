function specification = getSpecification(this, laState)
%GETSPECIFICATION   Get the specification.

%   Author(s): J. Schickler
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 06:57:24 $

if nargin < 2
    laState = this;
end

if strcmpi(laState.PulseShape, 'gaussian')
    specification = 'nsym,bt';
else
    switch lower(laState.OrderMode2)
        case 'minimum'
            specification = 'ast,beta';
        case 'specify order'
            specification = 'n,beta';
        case 'specify symbols'
            specification = 'nsym,beta';
    end
end

% [EOF]

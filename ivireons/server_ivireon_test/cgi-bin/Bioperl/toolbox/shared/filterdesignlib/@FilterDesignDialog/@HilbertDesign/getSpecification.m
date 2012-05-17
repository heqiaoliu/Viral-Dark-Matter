function specification = getSpecification(this, varargin)
%GETSPECIFICATION   Get the specification.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/06/11 17:23:33 $

if isminorder(this, varargin{:})
    specification = 'TW,Ap';
else
    specification = 'N,TW';
end

% [EOF]

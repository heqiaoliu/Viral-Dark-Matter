function multiratespectypes = getmultiratespectypes(this)
%GETMULTIRATESPECTYPES   Get the multiratespectypes.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:22:07 $

% By default we add all of the specificationtypes to the multirate object,
% but subclasses can overload this to remove any that are not valid.
multiratespectypes = set(this, 'Specification');

% [EOF]

function cSpecCon = getconstructor(this)
%GETCONSTRUCTOR Return the constructor for the specification type.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:01:04 $


if nargin < 2
    stype = get(this, 'SpecificationType');
end

switch lower(stype)
    case 'nsym,bt',
        %#function fspecs.psgaussnsym
        cSpecCon = 'fspecs.psgaussnsym';
    otherwise
        error(generatemsgid('internalError'), ...
            'InternalError: Invalid Specification Type.');
end

% [EOF]

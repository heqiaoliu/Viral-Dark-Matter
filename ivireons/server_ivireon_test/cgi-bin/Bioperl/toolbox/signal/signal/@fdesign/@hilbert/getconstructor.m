function cSpecCon = getconstructor(this, stype)
%GETCONSTRUCTOR   Return the constructor for the specification type.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/08/20 13:26:31 $

if nargin < 2
    stype = get(this, 'SpecificationType');
end

switch lower(stype)
    case 'n,tw',
        %#function fspecs.hilbord
        cSpecCon = 'fspecs.hilbord';
    case 'tw,ap',
        %#function fspecs.hilbmin
        cSpecCon = 'fspecs.hilbmin';
    otherwise
        error(generatemsgid('internalError'), 'InternalError: Invalid Specification Type.');
end

% [EOF]

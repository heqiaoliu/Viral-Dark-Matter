function cSpecCon = getconstructor(this, stype)
%GETCONSTRUCTOR   Get the constructor.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/08/20 13:26:04 $

if nargin < 2
    stype = get(this, 'SpecificationType');
end

switch lower(stype)
    case 'n,f,a',
        %#function fspecs.sbarbmag
        cSpecCon = 'fspecs.sbarbmag';
    case 'nb,na,f,a',
        %#function fspecs.sbarbmagiir
        cSpecCon = 'fspecs.sbarbmagiir';
    case 'n,b,f,a'
        %#function fspecs.multiband
        cSpecCon = 'fspecs.multiband';
    case 'nb,na,b,f,a'
        %#function fspecs.multibandiir
        cSpecCon = 'fspecs.multibandiir';
    otherwise
        error(generatemsgid('internalError'), 'InternalError: Invalid Specification Type.');
end


% [EOF]

function cSpecCon = getconstructor(this, stype)
%GETCONSTRUCTOR   Return the constructor for the specification type.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/08/20 13:26:28 $

if nargin < 2
    stype = get(this, 'SpecificationType');
end

switch lower(stype)
    case 'n',
        %#function fspecs.difford
        cSpecCon = 'fspecs.difford';      % Specify order, single-band
    case 'n,fp,fst',
        %#function fspecs.diffordmb
        cSpecCon = 'fspecs.diffordmb';    % Specify order, multi-band
    case 'ap',
        %#function fspecs.diffmin
        cSpecCon = 'fspecs.diffmin';      % Minimum-order, single-band
    case 'fp,fst,ap,ast',
        %#function fspecs.diffminmb
        cSpecCon = 'fspecs.diffminmb';    % Minimum-order, multi-band
    otherwise
        error(generatemsgid('internalError'), 'InternalError: Invalid Specification Type.');
end

% [EOF]

function b = isSupportedStructure(this, Hd)
%ISSUPPORTEDSTRUCTURE   True if the current structure is supported for fixed point.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/12/28 04:33:19 $

if nargin > 1
    if ischar(Hd)
        structure = Hd;
    else
        structure = get(classhandle(Hd), 'Name');
    end
else
    structure = get(this, 'Structure');
end

% Return true for those filters which have a public 'Arithmetic' that can
% be set to 'fixed'.
b = any(strcmpi(structure, {'df1sos' 'df1' 'df1t' 'df1tsos' 'dffir' 'df2' ...
    'dfasymfir' 'df2sos' 'latticeallpass' 'df2tsos' 'dffirt' 'df2t' ...
    'dfsymfir' 'latticear' 'cicdecim' 'cicinterp' 'firdecim' 'firsrc' ...
    'holdinterp' 'linearinterp' 'firinterp' 'firtdecim' 'latticemamax' ...
    'latticemamin' 'latticearma' 'scalar' 'delay' 'fd' 'farrowfd'}));

% [EOF]

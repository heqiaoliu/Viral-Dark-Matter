function validstructs = getvalidstructs(this)
%GETVALIDSTRUCTS   Get the validstructs.

%   Copyright  The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:43 $


if isfdtbxinstalled,
    validstructs = fdfvalidstructs(this);
else
    validstructs = {'df1sos','df2sos','df1tsos','df2tsos'};
end

% [EOF]

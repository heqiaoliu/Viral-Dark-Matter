function out = applynamedcolor(in, nametable, space)
%APPLYNAMEDCOLOR maps color names to color-space coordinates
%   OUT = APPLYNAMEDCOLOR(IN, NAMETABLE, SPACE) associates
%   a character string IN with the coordinates of SPACE, through
%   the use of NAMETABLE.  NAMETABLE is a cell array, typically
%   taken from the NamedColor2.NameTable field of a profile
%   structure corresponding to an ICC Named Color profile.
%   The first column of this array contains color names, as
%   character strings.  The second column contains the associated
%   coordinates in the Profile Connection Space (which may be
%   Lab or XYZ), in 'double' notation.  The third column is
%   optional; if present, it contains the associated device
%   coordinates in 'double' notation.  SPACE must be either
%   'PCS' or 'Device' and is used to select the 2nd or 3rd
%   column of NAMETABLE for output.
%
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/03 03:10:14 $ Poe
%   Original author:  Robert Poe 10/16/05

% Check input arguments
iptchecknargin(3, 3, nargin, 'applynamedcolor');
iptcheckinput(in, {'char'}, {'vector'}, 'applynamedcolor', 'IN', 1);
iptcheckinput(nametable, {'cell'}, {'2d'}, 'applynamedcolor', ...
              'NAMETABLE', 2);
iptcheckinput(space, {'char'}, {'vector'}, 'applynamedcolor', 'SPACE', 3);

if strcmp(lower(space), 'pcs')
    column = 2;
elseif strcmp(lower(space), 'device')
    column = 3;
else
    eid = 'Images:applynamedcolor:invalidInput';
    msg = 'Unrecognized SPACE; must be ''PCS'' or ''Device''.';
    error(eid, '%s', msg);
end

idx = strmatch(in, nametable(:, 1), 'exact');
if isempty(idx)
    eid = 'Images:applynamedcolor:nameNotFound';
    msg = 'Color name not found in table';
    warning(eid, '%s', msg);
    out = [];
elseif column == 3 & size(nametable, 2) < 3
    eid = 'Images:applynamedcolor:invalidInput';
    msg = 'Device coordinates unavailable in table';
    warning(eid, '%s', msg);
    out = [];
else
    out = nametable{idx, column};
end

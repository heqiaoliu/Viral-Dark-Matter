function col = getPatchColor(LineCol)
%Get a patch color corresponding to a given line color. The patch color is
%a brighter version of the line color (such as light blue patch for a blue
%colored line). The patch is used to render the confidence region on a
%response. 

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2008/12/29 02:08:03 $

if ischar(LineCol)
    % convert to normailized rgb
    col1 = idutils.char2rgb(LineCol);
end
col1(~col1) = col1(~col1)+0.8;
col = col1;

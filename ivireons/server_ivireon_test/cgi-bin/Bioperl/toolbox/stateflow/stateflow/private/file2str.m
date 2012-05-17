function str = file2str(fileName)

% Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/01 08:05:49 $

fid = fopen(fileName, 'r');
F = fread(fid);
str = char(F');
fclose(fid);

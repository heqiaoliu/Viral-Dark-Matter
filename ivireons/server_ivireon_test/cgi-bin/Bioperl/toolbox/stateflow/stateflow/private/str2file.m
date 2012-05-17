function str2file(str,filename)
% str2file(str,filename)

% Copyright 2003-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/03/17 23:27:44 $

fid = fopen(filename, 'w');

if fid==-1
    fprintf(1,'Failed to open file ''%s'' for writing.',filename);
    error('Stateflow:UnexpectedError','Failed to open file.');
end
fprintf(fid,'%s',str);
fclose(fid);


function c = file2char(filename)

% Copyright 1984-2004 The MathWorks, Inc. 
% $Revision: 1.1.6.4 $  $Date: 2004/12/20 16:44:26 $

f = fopen(filename);
c = native2unicode(fread(f,'uint8=>uint8')');
fclose(f);

function doclick(A)
%DOCLICK Processes ButtonDown on MATLAB objects.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2010/02/25 08:09:07 $
%   J.H. Roh & B.A. Jones 4-25-97.

ud = getscribeobjectdata(A);
p  = ud.HandleStore;

doclick(p)

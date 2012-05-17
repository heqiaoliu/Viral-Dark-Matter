function delete(hndl)
%SCRIBEHANDLE/DELETE Delete scribehandle object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.11.4.2 $  $Date: 2008/08/14 01:37:52 $

h=hndl.HGHandle;
if ishghandle(h)
    ud = getscribeobjectdata(h);
    MLObj = ud.ObjectStore;
    delete(MLObj);
    delete(hndl.HGHandle);
end

    


function close(this)
%CLOSE A method which is called to destroy the fileTree instance.
%
%   Function arguments
%   ------------------
%   THIS: the fileTree object instance.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:09:12 $

    delete(this);

end
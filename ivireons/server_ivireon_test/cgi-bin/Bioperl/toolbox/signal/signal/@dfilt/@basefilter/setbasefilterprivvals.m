function setbasefilterprivvals(this, privvals)
%SETBASEFILTERPRIVVALS   

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 16:01:09 $

% Get names of private properties we want to copy
pnames = basefilterprivnames(this);

set(this,pnames,privvals);

% [EOF]

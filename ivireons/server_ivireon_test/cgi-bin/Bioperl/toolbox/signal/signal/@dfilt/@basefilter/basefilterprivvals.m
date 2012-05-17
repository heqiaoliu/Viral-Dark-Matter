function privvals = basefilterprivvals(this)
%BASEFILTERPRIVVALS   

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 16:00:57 $

% Get names of private properties we want to copy
pnames = basefilterprivnames(this);

privvals = get(this,pnames);

% [EOF]

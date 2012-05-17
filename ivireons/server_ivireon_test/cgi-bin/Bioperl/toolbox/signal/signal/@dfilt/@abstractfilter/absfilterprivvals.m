function privvals = absfilterprivvals(this)
%ABSFILTERPRIVVALS   

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:59:53 $

privvals.parent = basefilterprivvals(this);

% Get names of private properties we want to copy
pnames = absfilterprivnames(this);

privvals.this = get(this,pnames);

% [EOF]

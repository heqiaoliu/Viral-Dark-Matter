function privvals = sosprivvals(this)
%SOSPRIVVALS   

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 16:00:48 $

privvals.parent = dfiltprivvals(this);

% Get names of private properties we want to copy
pnames = sosprivnames(this);

privvals.this = get(this,pnames);


% [EOF]

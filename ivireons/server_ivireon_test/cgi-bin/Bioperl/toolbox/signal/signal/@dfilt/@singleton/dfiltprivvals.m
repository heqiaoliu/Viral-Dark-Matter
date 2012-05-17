function privvals = dfiltprivvals(this)
%DFILTPRIVVALS   

%   Author(s): R. Losada
%   Copyright 2003-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:03 $

privvals.parent = absfilterprivvals(this);

% Get names of private properties we want to copy
pnames = dfiltprivnames(this);

privvals.this = get(this,pnames);


% [EOF]

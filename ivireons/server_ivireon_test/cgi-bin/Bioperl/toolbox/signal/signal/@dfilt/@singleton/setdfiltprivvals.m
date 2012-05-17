function setdfiltprivvals(this, privvals)
%SETDFILTPRIVVALS   Set private values.

%   Author(s): R. Losada
%   Copyright 2003-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:59:45 $

setabsfilterprivvals(this, privvals.parent);

% Get names of private properties we want to copy
pnames = dfiltprivnames(this);

set(this,pnames,privvals.this);

% [EOF]

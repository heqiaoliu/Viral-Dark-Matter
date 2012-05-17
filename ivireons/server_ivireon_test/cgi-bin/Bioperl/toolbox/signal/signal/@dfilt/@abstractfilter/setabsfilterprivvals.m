function setabsfilterprivvals(this, privvals)
%SETABSFILTERPRIVVALS   

%   Author(s): R. Losada
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:59:57 $

setbasefilterprivvals(this, privvals.parent);

% Get names of private properties we want to copy
pnames = absfilterprivnames(this);

set(this,pnames,privvals.this);

% [EOF]

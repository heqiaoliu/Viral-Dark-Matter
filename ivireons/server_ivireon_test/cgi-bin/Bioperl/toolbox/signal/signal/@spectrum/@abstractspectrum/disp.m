function disp(this)
%DISP   Spectrum object display method.
  
%   Author: P. Pacheco
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/13 00:17:19 $

s  = get(this);
fn = fieldnames(s);
props = reorderprops(this);
disp(s);

% [EOF]

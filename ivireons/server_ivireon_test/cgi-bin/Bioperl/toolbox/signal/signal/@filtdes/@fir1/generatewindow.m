function win = generatewindow(this)
%GENERATEWINDOW Generate the window used for the design.

%   Author(s): R. Losada, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:04:23 $

N = get(this,'order');

winobj = get(this, 'WindowObject');

set(winobj, 'length', N+1);
win = generate(winobj);

% [EOF]

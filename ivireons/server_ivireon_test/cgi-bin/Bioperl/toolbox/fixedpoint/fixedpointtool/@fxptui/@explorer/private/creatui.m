function creatui(h)
%CREATUI   Create the Fixed-Point Tool User Interface.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:14 $


createactions(h);
customize(h);
createmenu(h);
createtoolbar(h);
updateactions(h);

% [EOF]

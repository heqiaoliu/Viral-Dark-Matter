function hgS = hgsaveStructClass(h)
%hgsaveStructClass Save object handles to a structure.
%
%  hgsaveStructClass converts handles into a structure ready for saving.
%  This function is called when MATLAB is using objects as HG handles.

%   Copyright 2009 The MathWorks, Inc.

hgS = handle2struct(h);

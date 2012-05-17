function rebuild(h)
%REBUILD
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:29:05 $

% Hide graph editor if its visible. Clear the panel and re-initialize
% the GUI object
h.javaframe.reset(h);

% Display the gui
awtinvoke(h.javaframe,'setVisible',true);
h.Visible = 'on';

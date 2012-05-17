function h = preprocess(dataset)
%PREPROCESS
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:29:04 $

h = preprocessgui.preprocess;
h.initialize(dataset);

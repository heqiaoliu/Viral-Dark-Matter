function initialize(h,dataset)
%INITIALIZE
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:29:03 $

h.reset(dataset);

% Initialize exclusion rule
h.Exclusion = preprocessgui.exclusion;
h.Filtering = preprocessgui.filtering;    
h.Interp = preprocessgui.interp; 

% Add generic listeners
generic_listeners(h);
function [addPlan,addEdit] = createGUIPlan(this) 
% CREATEGUIPLAN create GUI components the visualization 
%
% This method is called by createGUI and allows subclasses to add their own
% widgets to the GUI
%
% [addPlan,addEdit] = createGUIPlan(this);
%
% Outputs:
%    addPlan - cell array with plug-in widgets to add to parent
%    addEdit - cell array of uimgr widgets to add to the edit menu item
%              added by the parent class
%

% Author(s): A. Stothert 11-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:31 $

addPlan = {};
addEdit = [];
end

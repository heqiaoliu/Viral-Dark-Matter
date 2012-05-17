function this = treeoptions(nlarxobj,h)
% Tree options panel object.
% h: handle to main java panel containing tree options (radion buttons
% and Advanced button) 

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:10 $

this = nloptionspack.treeoptions;

this.NlarxPanel = nlarxobj;
this.jMainPanel = h; %main Model Type panel
this.initialize;

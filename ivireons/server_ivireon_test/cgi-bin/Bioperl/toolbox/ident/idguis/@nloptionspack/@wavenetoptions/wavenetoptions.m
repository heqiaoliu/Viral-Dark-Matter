function this = wavenetoptions(nlarxobj,h)
% Wavenet options panel object.
% nlarxobj: handle to nlarxpanel UDD object
% h: handle to main java panel containing wavenet options (radion buttons
% and Advanced button) 

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:16 $

this = nloptionspack.wavenetoptions;

this.NlarxPanel = nlarxobj;
this.jMainPanel = h; 
this.initialize;

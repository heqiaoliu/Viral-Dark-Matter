function sync(this)
% Synchronizes dialog contents with loop data.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2006/05/27 18:02:33 $

% Update internal data
CurrentDesign = exportdesign(this.Parent.LoopData);
this.ConfigData = CurrentDesign;
this.CurrentData = CurrentDesign;

% Configure dialog
setconfig(this)

function show(h,Constr)
%SHOW  Points edit dialog to a particular constraint.

%   Authors: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:16 $

% RE: h = @tooleditor handle

% Retarget tooldlg to appropriate container/constraint
h.Dialog.show(h.Container,Constr);

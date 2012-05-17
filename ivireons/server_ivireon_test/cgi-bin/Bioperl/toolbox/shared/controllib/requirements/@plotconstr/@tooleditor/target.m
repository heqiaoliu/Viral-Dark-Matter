function target(h,Constr)
%TARGET  Points edit dialog to a particular constraint.

%   Authors: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:17 $

% RE: h = @tooleditor handle

% Retarget tooldlg to appropriate container/constraint
h.Dialog.target(h.Container,Constr);

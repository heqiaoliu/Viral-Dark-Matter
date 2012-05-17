function settype(h,Type)
%SETTYPE  Sets constraint type

%   Authors: P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:11 $

% Create constraint of specified type
NewConstr = h.Client.newconstr(Type,h.Constraint);

% Update constraint (will trigger update of param. editor groupbox)
if ~isequal(NewConstr,h.Constraint)
   delete(h.Constraint)
end
h.Constraint = NewConstr;   % always triggers listener
% RE: necessary for @pzdamping since both Damping and Overshoot are the same constraint

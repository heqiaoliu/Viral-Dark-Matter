function b = isvalidtreenode(h)
%ISVALIDTREENODE   True if the object is validtreenode.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:58:04 $

b = false;
clz = class(h.daobject);
switch clz
  case{'Simulink.SubSystem', 'Simulink.BlockDiagram', 'Stateflow.Chart'}
    b= true;
  otherwise
end

% [EOF]

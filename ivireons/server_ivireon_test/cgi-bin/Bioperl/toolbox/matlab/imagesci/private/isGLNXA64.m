function tf = isGLNXA64

% Copyright 2004 The MathWorks, Inc.

persistent compType;

if (isempty(compType))
  compType = computer;
end

tf = isequal(compType, 'GLNXA64');

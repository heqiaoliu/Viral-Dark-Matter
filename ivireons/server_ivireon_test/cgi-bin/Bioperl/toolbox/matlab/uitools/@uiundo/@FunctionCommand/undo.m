function undo(hThis)

% Copyright 2002-2005 The MathWorks, Inc.

try
    feval(hThis.InverseFunction,hThis.InverseVarargin{:});
catch ex
    newExc = MException('MATLAB:undo:CannotUndoCommand','Cannot undo command: %s');
    newExc = newExc.addCause(ex);
    throw(newExc);
end


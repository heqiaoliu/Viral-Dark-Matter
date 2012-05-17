function execute(hThis)

% Copyright 2002-2005 The MathWorks, Inc.

try 
  feval(hThis.Function,hThis.Varargin{:});
catch ex
   newExc = MException('MATLAB:execute:CommandExecutionFailed','Cannot execute command: ');
   newExc = newExc.addCause(ex);
   throw(newExc);
end
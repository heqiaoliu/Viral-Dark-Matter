function generateCode = vector_code_generation(sys)
%
%  VECTOR_CODE_GENERATION Returns whether code generation for the Vector 
%  CAN blocks should be run.
%
%  VECTOR_CODE_GENERATION(SYS) returns true if the target associated with model
%  SYS is GRT or ERT.   Otherwise, false is returned.
%

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $
% $Date: 2005/09/08 20:34:25 $
   sys_target_file = get_param(sys, 'RTWSystemTargetFile');
   tlcindex = findstr('.tlc', sys_target_file);
   target = sys_target_file(1:tlcindex-1);
   switch (target)
      case { 'grt', 'ert' }
         % testing and documentation not complete
         % disable this feature
         generateCode = false;
      otherwise
         generateCode = false;
   end;
return;

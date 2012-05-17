% TLC2M Converts TLC argument to MATLAB variable
%
%       tlc2m(mlvar,tlcvar)
%
%       When called from Target Language Compiler (TLC), this function
%       creates mlvar in the MATLAB base workspace with the equivalent
%       MATLAB representation for the TLC variable tlcvar.  For example,
%       the following TLC call:
%
%       %<FEVAL("tlc2m", "foo", CompiledModel)>
%
%       creates foo in the base MATLAB workspace with the equivalent
%       MATLAB representation of CompiledModel.
%
%       returns 1 on success and 0 on failure.

%       Copyright 1994-2010 The MathWorks, Inc.
%       $Revision: 1.3.2.4 $

function status = tlc2m(mlvar,tlcvar)
  
  if ~iscvar(mlvar)
      DAStudio.warning('RTW:utility:NotValidCVar', mlvar);
      status = 0;
      return;
  end
  
  assignin('base',mlvar,tlcvar);
  status = 1;

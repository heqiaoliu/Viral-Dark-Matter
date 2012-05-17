function OK = pCwdIsUnc(obj) %#ok
; %#ok Undocumented
%pCwdIsUnc indicate if cwd is UNC
%
%  OK = pCwdIsUnc(SCHEDULER)
%

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2006/06/27 22:34:51 $ 

% The current working directory can only be UNC on a PC where pwd starts
% with the string '\\'
OK = ispc && ~isempty(regexp(pwd, '^\\\\', 'once'));
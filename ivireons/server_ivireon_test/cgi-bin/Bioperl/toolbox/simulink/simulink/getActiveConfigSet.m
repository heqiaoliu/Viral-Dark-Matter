function h = getActiveConfigSet(mdl)
%GETACTIVECONFIGSET Return a handle to the active configuration set object
%   in a Simulink model.

%   Copyright 1994-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

  hMdl = get_param(mdl, 'Object');
 
  h = getActiveConfigSet(hMdl);
  
% LocalWords:  getActiveConfigSet mdl Simulink MathWorks hMdl param

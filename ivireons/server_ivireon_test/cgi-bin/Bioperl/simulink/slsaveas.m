function slsaveas(mdlR14, mdlOld, saveAsVersion, isSimulink) %#ok<INUSD>
%SLSAVEAS converts a Simulink 6.3 (R14 SP3) model into a Simulink 6.0 (R14) model.
%
%   WARNING: This function is being deprecated in R14. It will be removed in 
%   a future version of Simulink. Please use save_system instead.
%
%   See also SAVE_SYSTEM
  
%   Copyright 1990-2008 The MathWorks, Inc.
%
%   $Revision: 1.12.4.9 $
%   Ricardo Monteiro  10/23/2000

  DAStudio.error('Simulink:utility:removedFunction','SLSAVEAS','SAVE_SYSTEM');
  
  
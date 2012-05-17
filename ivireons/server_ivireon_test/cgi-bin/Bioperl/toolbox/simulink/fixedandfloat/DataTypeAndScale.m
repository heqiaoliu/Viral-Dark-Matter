function [dataType scaling] = DataTypeAndScale(unevaledContainerTypeStr, unevaledScalingStr)
%DataTypeAndScale
%
% This is a dumb function which returns its two string arguments This function 
% is for Simulink internal use only. Other usage of this function is NOT 
% supported.
% 
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $
% $Date: 2007/11/17 23:23:12 $
%
  assert(ischar(unevaledContainerTypeStr));  
  assert(ischar(unevaledScalingStr));  

  dataType = unevaledContainerTypeStr;
  scaling = unevaledScalingStr;

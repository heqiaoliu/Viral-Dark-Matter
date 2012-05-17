function setrtwoption(modelname,opt,val,create)
%SETRTWOPTION sets an RTW option for a Simulink model
%   OPT=SETRTWOPTION(MODELNAME, OPT, VALUE, CREATE) sets the RTW option OPT to VALUE for 
%   Simulink model MODELNAME. If CREATE = 1 the option is created if necessary, otherwise
%   an error is thrown if the option does note exist.
%
%   This function is now obsolete. Use set_param instead.

%   Copyright 2002-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $
%   $Date: 2007/11/13 00:13:27 $

TargetCommon.ProductInfo.warning('common', 'ObsoleteFunction2', mfilename);
  set_param(modelname,opt,val);

function val=getrtwoption(modelname,opt)
%GETRTWOPTION gets an RTW option for a Simulink model
%   VALUE = GETRTWOPTION(MODELNAME, OPT) returns the VALUE of the RTW 
%   option OPT for Simulink model MODELNAME.

%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $
%   $Date: 2007/11/13 00:13:16 $

  TargetCommon.ProductInfo.warning('common', 'ObsoleteFunction', mfilename);

  opts = get_param(modelname,'RTWOptions');
  
  if isempty(findstr(opts,['-a' opt '=']))
    val = '';
    return
  end
  
  [s,f,t] = regexp(opts, ['-a' opt '=\"([^"]*)\"']);
  
  isNumeric=0;
  if isempty(s)
    % Numeric values are not double quoted
    [s,f,t] = regexp(opts, ['-a' opt '=(\d*)']);
    isNumeric=1;
  end
  
  t1 = t{1};
  
  if isempty(t1)
    val = '';
  else
    if isNumeric==0
      val = opts(t1(1):t1(2));
    else
      eval(['val = ' opts(t1(1):t1(2)) ';']);
    end
  end 

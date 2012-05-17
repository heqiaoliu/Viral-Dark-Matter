function hidecrit()
%  HIDECRIT hide the 'critical frequency' parameter in a mask dialog
%
%  Set up usage of this callback after selecting the block
%  you wish to hide the critical frequency edit field and type:
%
%  set_param(gcb,'MaskCallbacks',{'', '', '', 'hidecrit', ''});
%
%  It is then invoked when a discrete method is selected from a
%  list of zoh, foh, tustin, prewarp or matched.  Only the 
%  prewarp selection displays the Critical Frequency parameter
%
%  Lihai Qin

% $Revision: 1.4.4.2 $ $Date: 2005/06/17 20:43:09 $
% Copyright 1990-2005 The MathWorks, Inc.


maskType = get_param(gcb,'MaskType');

switch maskType
  case 'DiscretizedTransferFcn'
    method = get_param(gcb,'method');
    if strcmp(method,'prewarp')
      set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','on'});
    else
      set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','off'});
    end
  case 'DiscretizedZeroPole'
    method = get_param(gcb,'method');
    if strcmp(method,'prewarp')
      set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','on','on'});
    else
      set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','on','off'});
    end
  case 'DiscretizedStateSpace'
    method = get_param(gcb,'method');
    if strcmp(method,'prewarp')
      set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','on','on','on','on'});
    else
      set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','on','on','on','off'});
    end
  case 'DiscretizedDerivative'
    method = get_param(gcb,'method');
    if strcmp(method,'prewarp')
      set_param(gcb,'MaskVisibilities',{'on','on','on'});
    else
      set_param(gcb,'MaskVisibilities',{'on','on','off'});
    end
  case 'DiscretizedLTISystem'
      method = get_param(gcb, 'method');
    if strcmp(method,'prewarp')
      set_param(gcb,'MaskVisibilities',{'on','on','on','on','on'});
    else
      set_param(gcb,'MaskVisibilities',{'on','on','on','on','off'});
    end    
 case 'DiscretizedTransferFcnWithIC'
  method = get_param(gcb, 'method');
  if strcmp(method,'prewarp')
    set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','on'});
  else
    set_param(gcb,'MaskVisibilities',{'on','on','on','on','on','off'});
  end          
  otherwise
    disp('Mask dynamic dialog callback ''hidecrit()'' doesn''t know this mask type');
end

% end of hidecrit()
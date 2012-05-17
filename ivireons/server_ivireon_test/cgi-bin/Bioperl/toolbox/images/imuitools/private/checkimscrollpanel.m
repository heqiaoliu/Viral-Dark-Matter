function hpanel = checkimscrollpanel(varargin)
%CHECKIMSCROLLPANEL Check image scrollpanel.
%   HPANEL = CHECKIMSCROLLPANEL(HIMAGE,FUNCTION_NAME,VARIABLE_NAME) returns the
%   imscrollpanel associated with HIMAGE. If no imscrollpanel is found,
%   CHECKIMSCROLLPANEL errors.
  
%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/08/20 22:55:58 $

iptchecknargin(3, 3, nargin, mfilename);
himage = varargin{1};
iptcheckhandle(himage,{'image'},mfilename,'HIMAGE',1)

function_name = varargin{2};
variable_name = varargin{3};

hpanel = imshared.getimscrollpanel(himage);

if isempty(hpanel)
    eid =  sprintf('Images:%s:invalidScrollpanel',function_name);
    error(eid,'Function %s expected %s to be in an IMSCROLLPANEL.',...
          upper(function_name),variable_name)
end

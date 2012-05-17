function deletehgfig(varargin)
% This is function used by SIMULINK to delete any Handle Graphics figure
% which was created by SIMULINK.
  
%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $ $Date: 2008/06/20 08:48:42 $
  
if nargin ~= 1 || nargout > 0
    DAStudio.error('Simulink:util:InvalidCallToDeleteHGFig');
end

figHdl = varargin{1};

if ishandle(figHdl)
    delete(figHdl);
end

% end deletehgfig

% [EOF]

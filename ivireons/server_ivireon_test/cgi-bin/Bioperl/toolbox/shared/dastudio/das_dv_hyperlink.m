function das_dv_hyperlink(varargin) 
% function das_dv_hyperlink(dv_name, linkType, link) 
% 
% This function is intended to be invoked when a user clicks a hyperlink
% in a message displayed in the Diagnostic Viewer window. See the
% DAStudio.DiagMsg.findhtmllinks method for more info.
%
%   Copyright 2002-2008 The MathWorks, Inc.

  if nargin == 3
    dv_name = varargin{1};
    linkType = varargin{2};
    link = varargin{3};
    dv = DAStudio.DiagViewer.findInstance(dv_name);
  else
     % Fix for g502916. The S-Function builder creates its own 
     % dv client based on the old Java-based DV. Need to support
     % the Java-based viewer's assumption that only one dv instance
     % exists.
    linkType = varargin{1};
    link = varargin{2};
    rt = DAStudio.Root;
    dv = rt.find('-isa','DAStudio.DiagnosticViewer');
  end
  
  dv.hyperlink(linkType, link);

end






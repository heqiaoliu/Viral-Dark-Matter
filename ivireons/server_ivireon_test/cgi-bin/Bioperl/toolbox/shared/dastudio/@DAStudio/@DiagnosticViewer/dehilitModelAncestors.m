
%-----------------------------------------------------------------
function  dehiliteModelAncestors(h),
%  DEHILITE__ANCESTORS
%  This function will dehilite the ancestors of the model
%  associated with the Diagnostic Viewer
%  Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/11/19 16:45:35 $
 
%

% dehilite the ancestors of the model
  sysH = h.modelH;
  if ishandle(sysH)
    set_param(sysH, 'HiliteAncestors', 'off');
  end;
%------------------------------------------------------------------------------
 

function CheckDir(h) %#ok<INUSD>
%----------------------------------------------------------------------%
% Check for UNC directory on Windows or under MATLABROOT on all        %
% platforms to avoid corrupting product or RTW project directories.    %
% MATLABROOT/Work will be accepted on PC.                              %
%----------------------------------------------------------------------%
  
%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2008/06/20 08:08:48 $
  
%Error out if matlabroot contains dollar signs ($) in the path
ispc = strncmp(computer,'PC',2);
if ispc && ~isempty(findstr('$', matlabroot))
    DAStudio.error('RTW:makertw:matlabInstallDirError');
 end

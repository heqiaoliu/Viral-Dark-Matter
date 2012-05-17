function [choices] = rootobjectenum(field)
%ROOTOBJECTENUM Simulink Root Object Enumerator.
%   ROOTOBJECTENUM provides the functions for populating the combo boxes in the
%   Simulink preferences dialog.

%   $Revision: 1.5.2.1 $ 
%   Copyright 1990-2002 The MathWorks, Inc.

if nargin < 1
  DAStudio.error('Simulink:utility:invNumArgsWithAbsValue',mfilename,1);
end

choices = getfield(getfield(get_param(0,'ObjectParameters'),field),'Enum');
choices{end + 1} = get_param(0,field);


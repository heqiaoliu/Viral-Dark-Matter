function [sys1,sys2] = matchDisplayFormat(sys1,sys2)
% Enforces matching display formats.
%    [SYS1,SYS2] = ltipack.matchDisplayFormat(SYS1,SYS2)
% The preference rules for the display format are
%     t > f > r

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:28:53 $
DF1 = sys1.DisplayFormat;
DF2 = sys2.DisplayFormat;
if ~strcmp(DF1,DF2)
   % Reconcile display formats if non matching
   if strncmp(DF1,'t',1) || strncmp(DF2,'t',1)
      Format = 'time constant';
   else
      Format = 'frequency';
   end
   sys1.DisplayFormat = Format;
   sys2.DisplayFormat = Format;
end

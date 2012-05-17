function [lim,strict] = getlowerbound(hOutlier)
%GETLOWERBOUND Get the lower bound for an exclusion rule

% $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:22:14 $
% Copyright 2003-2004 The MathWorks, Inc.

% Start with default, indicating no lower bound
lim = -Inf;
strict = false;

% Get the real bound if it has a valid definition
if ~isempty(hOutlier.YLow)
   try
      lim = str2num(hOutlier.YLow);
      strict = (hOutlier.YLowLessEqual == 1);
   catch
   end
end

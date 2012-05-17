function t = parforfinal(varargin)
%PARFORFINAL                     Private utility function for parallel

%PARFORFINAL Final value for PARFOR on each processor.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2009/07/14 03:53:48 $

if parfor_depth == 1
   c = getLocalPart(codistributed.colon(varargin{:}, 'noCommunication'));
   if isempty(c)
       t = c;
   else
       t = c(end);
   end
else
   t = varargin{end};
end

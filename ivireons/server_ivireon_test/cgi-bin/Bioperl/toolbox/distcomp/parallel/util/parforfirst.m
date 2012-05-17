function s = parforfirst(varargin)
%PARFORFIRST                     Private utility function for parallel

%PARFORFIRST  Starting value for PARFOR on each processor.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2009/07/14 03:53:49 $

if parfor_depth == 1
   c = getLocalPart(codistributed.colon(varargin{:}, 'noCommunication'));
   if isempty(c)
       s = c;
   else
       s = c(1);
   end
else
   s = varargin{1};
end

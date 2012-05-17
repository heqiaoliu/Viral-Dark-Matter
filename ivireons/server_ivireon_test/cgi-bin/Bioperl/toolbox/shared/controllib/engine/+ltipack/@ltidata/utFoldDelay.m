function D = utFoldDelay(D,InputDelay,OutputDelay)
% Folds specified subset of input and output delays into
% internal delays. Default implementation for models
% with internal delays restricted to I/O delays

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:29 $
if ~isempty(InputDelay) && any(InputDelay)
   ny = length(D.Delay.Output);
   D.Delay.IO = D.Delay.IO + repmat(InputDelay.',[ny 1]);
   D.Delay.Input = D.Delay.Input - InputDelay;
end

if ~isempty(OutputDelay) && any(OutputDelay)
   nu = length(D.Delay.Input);
   D.Delay.IO = D.Delay.IO + repmat(OutputDelay,[1 nu]);
   D.Delay.Output = D.Delay.Output - OutputDelay;
end


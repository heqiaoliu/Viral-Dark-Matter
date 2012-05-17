function [D,SingularFlag] = lft(D1,D2,varargin)
% LFT interconnection.

%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:43 $
try
   [Dss,SingularFlag] = lft(ss(D1),ss(D2),varargin{:});
catch ME
   throw(ME)
end
try
   D = zpk(Dss);
catch %#ok<CTCH>
    ctrlMsgUtils.error('Control:combination:InternalDelaysConvert2SS')
end  

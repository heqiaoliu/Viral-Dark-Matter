function sys = utCreateLTI(D)
% Creates LTI object wrapper given internal @ltidata representation

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:57 $
if ~isscalar(D)
    ctrlMsgUtils.error('Control:general:RequiresSingleModel','utCreateLTI')
end
sys = setPrivateData(ss(zeros(iosize(D))),D);

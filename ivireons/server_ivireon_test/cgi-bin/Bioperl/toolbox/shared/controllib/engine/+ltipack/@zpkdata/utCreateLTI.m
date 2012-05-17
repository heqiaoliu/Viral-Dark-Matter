function sys = utCreateLTI(D)
% Creates LTI object wrapper given internal @ltidata representation

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:34:06 $
if ~isscalar(D)
    ctrlMsgUtils.error('Control:general:RequiresSingleModel','utCreateLTI')
elseif D.Ts==0
   sys = zpk(zeros(iosize(D)));
else
   sys = zpk(zeros(iosize(D)),'Ts',-1);  % to get correct Variable
end
sys = setPrivateData(sys,D);

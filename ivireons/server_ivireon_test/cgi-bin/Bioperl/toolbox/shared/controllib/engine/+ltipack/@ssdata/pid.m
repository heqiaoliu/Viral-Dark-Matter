function PIDDATA = pid(SSDATA,varargin)
% Converts to PID data object 

%   Author(s): Rong Chen
%   Copyright 2009 MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2010/02/08 22:47:46 $

% error out if time delay exists
if hasdelay(SSDATA)
    ctrlMsgUtils.error('Control:ltiobject:pidNoConversionWithTimeDelay');
else
    try
        PIDDATA = pid(zpk(SSDATA),varargin{:});
    catch E
        throw(E)
    end
end
function rawData = getRawData(this, index)
%GETRAWDATA Get the rawData.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:16 $

% if isRunning(this)
    
%     sigData = this.SLConnectMgr.getSignalData;
%     rawData = {sigData.UserData};
    
%     rtos = sigData.RTO;
%     if nargin > 1
%         rawData = rtos(index).OutputPort(sigData.portIdx(index)).Data;
%     else
%         rawData = cell(1, numel(rtos));
%         for indx = 1:numel(rtos)
%             rawData{indx} = rtos(indx).OutputPort(sigData.portIdx(indx)).Data;
%         end
%     end
% else
    rawData = this.RawDataCache;
    if nargin > 1
        rawData = rawData{index};
    end
% end

% [EOF]

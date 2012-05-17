function FreqData = getMultiModelFrequency(this)
%getMultiModelFrequency  

%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.2.2.1 $  $Date: 2010/07/12 15:20:12 $

if this.MultiModelFrequencySelectionData.UseAutoMode
    if isempty(this.MultiModelFrequencySelectionData.AutoModeData)
        %Recompute
        localComputeFreqGrid(this)
    end
    FreqData= this.MultiModelFrequencySelectionData.AutoModeData;
else
    FreqData = this.MultiModelFrequencySelectionData.UserModeData;
end

if this.Target.LoopData.Ts ~= 0
    FreqData = FreqData(FreqData<=pi/this.Target.LoopData.Ts);
end
    
    
function localComputeFreqGrid(this)

P = this.Target.LoopData.Plant.getP;

if isa(P,'ltipack.frddata')
    NewData = P.Frequency;
    
else
for ct = 1:length(P)
   [~,~,~,FocusInfo(ct,1)] = freqresp(P(ct),3,[],false);
end

Focus = mrgfocus({FocusInfo(:,1).Focus}',vertcat(FocusInfo(:,1).Soft));

if isempty(Focus)
   Focus = [.1, 100];
end


Upper = ceil(log10(Focus(2)))+1;
Lower = floor(log10(Focus(1)))-1;
NewData = logspace(Lower,Upper,(Upper-Lower)*50);
end

this.MultiModelFrequencySelectionData.AutoModeData = NewData;
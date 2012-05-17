function registerCharacteristics(this,varargin)
%registerCharacteristics  Registers characteristics
% registerCharacteristics(this,waveform)
% registerCharacteristics(this,ID,Label)

%  Copyright 2009-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.2 $ $Date: 2010/04/11 20:36:32 $

if length(varargin)==1
    % registerCharacteristics(this,waveform)
    waveform = varargin{1};
    [CharIDs,CharLabels,CharGroups] = waveform.getCharacteristicIDs;
else
    % registerCharacteristics(this,ID,Label,isVisible)
    CharIDs = varargin(1);
    CharLabels = varargin(2);
    waveform = [];
end
    
    
for ct = 1:numel(CharIDs)
    CharID = CharIDs{ct};
    [b,idx] = hasCharacteristic(this,CharID);
    if b && ~isempty(waveform)
        this.CharacteristicManager(idx).Waveforms = ...
            [this.CharacteristicManager(idx).Waveforms; waveform];
        if this.CharacteristicManager(idx).Visible
            showCharacteristic(waveform,CharID)
        end
    elseif ~b
        if isempty(this.CharacteristicManager)
            this.CharacteristicManager = struct(...
                'CharacteristicID', CharID, ...
                'CharacteristicLabel', CharLabels{ct}, ...
                'CharacteristicGroup', CharGroups{ct}, ...
                'Waveforms', waveform, ...
                'Visible', false);
        else
            this.CharacteristicManager(end+1,1) = struct(...
                'CharacteristicID', CharID, ...
                'CharacteristicLabel', CharLabels{ct}, ...
                'CharacteristicGroup', CharGroups{ct}, ...
                'Waveforms', waveform, ...
                'Visible', false);
        end
    end
end

    

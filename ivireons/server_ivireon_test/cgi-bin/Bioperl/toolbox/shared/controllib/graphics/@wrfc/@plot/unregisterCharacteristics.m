function unregisterCharacteristics(this, waveform)
%unregisterCharacteristics  Unregister characteristics

%  Copyright 2009-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:53:20 $

CharIDs = waveform.getCharacteristicIDs;
 
for ct = 1:numel(CharIDs)
    CharID = CharIDs{ct};
    [b,idx] = hasCharacteristic(this,CharID);
    if b
        Waveforms = this.CharacteristicManager(idx).Waveforms;
        Waveforms(waveform == Waveforms) = [];
        % Remove waveform from registration list
        this.CharacteristicManager(idx).Waveforms = Waveforms;
    end
end


% for ct = 1:numel(CharIDs)
%     CharID = CharIDs{ct};
%     [b,idx] = hasCharacteristic(this,CharID);
%     if b
%         Waveforms = this.CharacteristicManager(idx).Waveforms;
%         Waveforms(waveform == Waveforms) = [];
%         if isempty(Waveforms)
%             % Remove characteristic (e.g. last waveform to register it)
%             this.CharacteristicManager(idx) = [];
%         else
%             % Remove waveform from registration list
%             this.CharacteristicManager(idx).Waveforms = Waveforms;
%         end
%     end
% end
function showCharacteristic(this, CharID)
%showCharacteristic  Show characteristics on the plot with CharID

%  Copyright 2009-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:53:19 $

% Determine if plot has the characteristic registered
[b,idx] = hasCharacteristic(this,CharID);
if b
    % Set characteristic manager state
    this.CharacteristicManager(idx).Visible = true;
    
    % Show characteristics for each waveform
    wf = this.CharacteristicManager(idx).Waveforms;
    for ct = 1:numel(wf)
        showCharacteristic(wf(ct), CharID)
    end
    % Required for plot to be updated with characteristics displayed
    draw(this)
else
    ctrlMsgUtils.warning('Controllib:plots:CharacteristicNotSupported', CharID)
end


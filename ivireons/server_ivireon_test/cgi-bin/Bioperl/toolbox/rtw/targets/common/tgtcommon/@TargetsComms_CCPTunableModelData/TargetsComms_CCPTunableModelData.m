%TARGETSCOMMS_CCPTUNABLEMODELDATA class representing TunableModelData for CCP communications
%   TARGETSCOMMS_CCPTUNABLEMODELDATA class representing TunableModelData for CCP communications

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/15 15:04:29 $

classdef TargetsComms_CCPTunableModelData < TargetsMemoryMappedData_TunableModelData

  methods
    
    % td_ccp = TargetsComms_CCPTunableModelData()

    % This method returns matching symbols from the collection based on eventChannel
    function matchedSymbol = getSymbolsWithEventChannel(this, eventChannel)
      matchedSymbol = {};
      for i=1:length(this.symbolList)
        if isa(this.symbolList{i}, 'TargetsComms_DAQSignal') && (this.symbolList{i}.eventChannel == eventChannel) 
          matchedSymbol(end + 1) = this.symbolList(i);
        end        
      end
    end
    
  end % methods

end % classdef
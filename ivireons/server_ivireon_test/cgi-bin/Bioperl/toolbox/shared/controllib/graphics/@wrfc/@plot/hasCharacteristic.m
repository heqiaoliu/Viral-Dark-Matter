function [b,idx] = hasCharacteristic(this,CharID)
%hasCharacteristic  Determines if characteristics exists in the
%Characteristic Manager

%  Copyright 2009-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:53:14 $

if isempty(this.CharacteristicManager)
    b = false;
    idx = [];
else
    idx = find(strcmp(CharID,{this.CharacteristicManager.CharacteristicID}));
    b = ~isempty(idx);
end

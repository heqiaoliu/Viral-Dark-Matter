function setCharacteristics(this,CharInfo)
%setCharacteristics  Sets waveforms characteristics

%  Copyright 2009-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:53:12 $

this.CharacteristicManager = CharInfo;
registerCharacteristics(this.parent,this);
function hideCharacteristic(this, CharID)
%hideCharacteristic  hide characteristics

%  Copyright 2009-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2010/02/08 22:53:10 $


wfChar = this.Characteristics(strcmpi(get(this.Characteristics,'Identifier'), ...
      CharID));

if ~isempty(wfChar)
    set(wfChar,'Visible','off');
end



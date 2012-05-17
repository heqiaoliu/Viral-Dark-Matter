function numberofbands = set_numberofbands(this, numberofbands)
%SET_NUMBEROFBANDS   PreSet function for the 'numberofbands' property.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:16:39 $

oldNBands = this.NumberOfBands;

set(this, 'privNumberOfBands', numberofbands);

% Create new band objects when we need them.
for indx = oldNBands+1:numberofbands
    bandProp = sprintf('Band%d', indx+1);
    if isempty(this.(bandProp))
        this.(bandProp) = FilterDesignDialog.ArbMagBand;
    end
end

updateMethod(this);

% [EOF]

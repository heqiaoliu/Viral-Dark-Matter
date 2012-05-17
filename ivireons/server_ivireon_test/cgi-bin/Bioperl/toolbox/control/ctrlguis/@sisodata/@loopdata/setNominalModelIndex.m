function setNominalModelIndex(this,Index)
%setNominalModelIndex  Sets the index for the nominal model.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:22:20 $

Plant = this.Plant;
Loops = this.L;

if (mod(Index,1) == 0) && (Index <= length(Plant.getP))&&(Index > 0)
    Plant.setNominalModelIndex(Index)
    for ct = 1:length(Loops)
        Loops(ct).Nominal = Index;
    end
    this.dataevent('all')
else
    error('string')
end
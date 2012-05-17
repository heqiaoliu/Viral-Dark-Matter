function getInitialOutput(this,characteristic,gridsize,simout)
%  GETINITIALOUTPUT obtains the operating point value data corresponding to the
%  channel and places it in the data of the characteristic.
%
%


% Author(s): Erman Korkut 18-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:00 $

% Write the DC values for all IO pairs
for ctin = 1:gridsize(2)
    for ctout = 1:gridsize(1)
        characteristic.Data.FinalValue(ctout,ctin) = simout{ctout,ctin}.Data(1,1);
    end
end
















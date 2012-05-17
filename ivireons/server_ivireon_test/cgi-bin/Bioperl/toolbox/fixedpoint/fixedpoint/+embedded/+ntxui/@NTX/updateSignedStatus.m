function updateSignedStatus(ntx)
% Update IsSigned status based on histogram data and OptionsSigned mode.
%
% For 'auto' mode:
%    Floating point: unsigned unless negative values were recorded
%    Fixed point: follows signedness of fi object

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:11 $

dlg = ntx.hBitAllocationDialog;
switch dlg.BASigned
    case 1 % Auto
        % Assume unsigned format unless a negative number is observed
        ntx.IsSigned = ntx.DataNegCnt > 0;
    case 2 % Signed
        ntx.IsSigned = true;
    case 3 % Unsigned
        ntx.IsSigned = false;
end

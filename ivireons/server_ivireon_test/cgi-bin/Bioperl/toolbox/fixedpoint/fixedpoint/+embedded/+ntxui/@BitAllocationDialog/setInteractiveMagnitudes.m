function setInteractiveMagnitudes(dlg,newOverExp,newUnderExp,wasExtraMSBBitsAdded,wasExtraLSBBitsAdded)
% Determine magnitude values from exponents
% Copy values (not exponent) into magnitudes

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2.2.1 $     $Date: 2010/07/06 14:39:03 $

% remove the previously added extra bits before setting the interactive magnitudes.
if dlg.extraMSBBitsSelected && wasExtraMSBBitsAdded
    newOverExp = newOverExp - dlg.BAILGuardBits;
end
if dlg.extraLSBBitsSelected && wasExtraLSBBitsAdded
    newUnderExp = newUnderExp + dlg.BAFLExtraBits;
end
dlg.BAILMagInteractive = pow2(newOverExp);
dlg.BAFLMagInteractive = pow2(newUnderExp);


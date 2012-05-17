function s = getNumericTypeStrs(ntx)
% Returns structure with strings describing numeric type

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/05/20 02:17:58 $

% Include guard- and precision-bits
[~,fracBits,wordBits,isSigned] = getWordSize(ntx,1);

% Setup common strings
if isSigned
    isSignedTF ='true';
    s.signedStr = 'Signed';
else
    isSignedTF = 'false';
    s.signedStr = 'Unsigned';
end
s.typeStr = sprintf('numerictype(%s,%d,%d)', ...
    isSignedTF, wordBits, fracBits);

s.typeTip = sprintf([ ...
    'Signedness: %s\n' ...
    'WordLength: %d\n', ...
    'FractionLength: %d'], ...
    s.signedStr,wordBits,fracBits);

s.warnTip = sprintf([ ...
    'The selected unsigned format will cause \n' ...
    'the negative values to be outside the range']);

s.isWarn = ~ntx.IsSigned && (ntx.DataNegCnt > 0);

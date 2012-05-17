function copyNumericTypeToClipboard(ntx)
% Copy numerictype text string into system clipboard
% for use with cut-and-paste.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:20:59 $

% Include guard- and precision-bits
[~,fracBits,wordBits,isSigned] = getWordSize(ntx,true);
if isSigned
    isSignedTF ='true';
else
    isSignedTF = 'false';
end
str = sprintf('numerictype(%s,%d,%d)', ...
    isSignedTF, wordBits, fracBits);

% Place string into the OS-specific cut buffer, as if "cut" was invoked
% This way, the datatype can be pasted into any application.
com.mathworks.mwswing.datatransfer.MJClipboard.getMJClipboard.setContents(str,[]);

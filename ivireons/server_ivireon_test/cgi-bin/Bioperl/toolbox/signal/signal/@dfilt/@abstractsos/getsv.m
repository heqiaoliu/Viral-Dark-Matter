function sv = getsv(Hd,sv)
%GETSV PreGet function for the scale values

%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/12 23:52:21 $

svq = Hd.privScaleValues;
isnoteq2one = Hd.issvnoteq2one;
sv = ones(length(isnoteq2one),1);
% Insert non unity scale values
sv(isnoteq2one) = double(svq);



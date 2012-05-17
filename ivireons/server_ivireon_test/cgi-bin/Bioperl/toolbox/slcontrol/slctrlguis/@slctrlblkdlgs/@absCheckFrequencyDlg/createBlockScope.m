function hScope = createBlockScope(MaskType, dlgPos, Src)
%

% Author(s): A. Stothert 07-Feb-2010
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:56:34 $

% CREATEBLOCKSCOPE  construct visualization for check block
%
 
hScope = slctrlguis.checkblkviews.FreqScope(MaskType,dlgPos,Src);
end
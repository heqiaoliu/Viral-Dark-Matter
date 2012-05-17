
%-----------------------------------------------------------------
function  dehilite_previously_hilit_blocks(h),
%  DEHILITE_PREVIOUSLY_HILIT_BLOCKS
%  This function will dehilit all previously
%  hilited blocks
%  Copyright 1990-2005 The MathWorks, Inc.
  
%  $Revision: 1.1.6.4 $ 
 
%
  wState = warning;
  warning off; % fix for g216390
  
  for bidx = 1:length(h.prevHilitObjs)
    blockH   = h.prevHilitObjs(bidx);
    blockClr = h.prevHilitClrs{bidx};
    if ishandle(blockH),
        try, set_param(blockH,'HiliteAncestors',blockClr); end;
    end;
  end
  h.prevHilitObjs = [];
  h.prevHilitClrs = {};

  warning(wState);

%------------------------------------------------------------------------------
 
%   $Revision: 1.1.6.4 $  $Date: 2005/06/24 11:09:03 $

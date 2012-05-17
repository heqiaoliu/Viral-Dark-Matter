function  dehilitBlocks(h)
%  DEHILITBLOCKS
%
%  Remove highlighting from blocks highlighted by the Diagnostic Viewer.
%
%  Copyright 1990-2008 The MathWorks, Inc.
 
  wState = warning;
  warning off all; % fix for g216390
  
  for bidx = 1:length(h.prevHilitObjs)
    blockH   = h.prevHilitObjs(bidx);
    blockClr = h.prevHilitClrs{bidx};
    if ishandle(blockH),
        try set_param(blockH,'HiliteAncestors',blockClr); end %#ok<TRYNC>
    end
  end
  h.prevHilitObjs = [];
  h.prevHilitClrs = {};

  warning(wState);
  
end
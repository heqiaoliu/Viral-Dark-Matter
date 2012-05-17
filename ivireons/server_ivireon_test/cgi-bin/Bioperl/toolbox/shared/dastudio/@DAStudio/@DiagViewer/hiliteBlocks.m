function hiliteBlocks(h, blockHandles)
%  HILITEBLOCKS
%
%  Highlight blocks associated with an error message.
%
%  Copyright 1990-2008 The MathWorks, Inc.

  hiliteH = blockHandles;

  for bidx = 1:length(hiliteH)
      blockH = hiliteH(bidx);
      if ~ishandle(blockH)
          continue;
      end
      
      % Set the hiliting of new error ON
      try
          isABlock = strcmp(get_param(blockH, 'Type'),'block');
          if isABlock
            if ~strcmp(get_param(blockH,'iotype'),'none')
              bd = bdroot(blockH);
              sigandscopemgr('Create',bd);
            else
              h.prevHilitObjs = [h.prevHilitObjs, blockH];
              color =  get_param(blockH,'HiliteAncestors');
              h.prevHilitClrs = [h.prevHilitClrs; {color}];
              hilite_system(blockH,'error');
            end;
          end;
      catch  %#ok<CTCH>
        % Ignore errors caused by highlighting blocks.
      end
  end
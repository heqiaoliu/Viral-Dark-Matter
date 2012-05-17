function hiliteBlocks(h, blockHandles)
%  HILITEBLOCKS
%
%  This is the function that hilites the blocks
%  Copyright 1990-2007 The MathWorks, Inc.
  
%   $Revision: 1.1.6.7 $  $Date: 2007/10/15 23:27:56 $
  
% hilits the new one.
% Get this info from the h (handle of the diagnosticViewer)
%
%
% if the last block hilit was you, just return;
%
  hiliteH = blockHandles;
  
  %oldLastErr = lasterr;  % cache lasterr

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
      catch          
      end
  end

  % Restore lasterr
  %lasterr(oldLastErr);
  
%-----------------------------------------------------------------
 





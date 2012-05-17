function optimizedelaychains(hTar)
%OPTIMIZE_DELAY_CHAINS Replace delay chains with single integer delay.
%   Detects cascaded delay blocks, and replaces all cascades
%   with a single integer delay block with its delay parameter
%   set appropriately.  Each block in the cascade must have
%   only one block destination; branch points terminate a cascade.

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:48 $

sys = hTar.system;
if isempty(sys), error(generatemsgid('NotSupported'),'System undefined.'); end

% 1 Generate list of candidate delay blocks
% 2 Examine block list and find a sequence of cascaded blocks
% 3 If any exist,
%     replace the cascade,
%     remove the cascaded blocks from the list, and
%     return to step 1
% 4 If no cascadable blocks remain,
%     return to the caller.
%
delay_blocks        = find_all_delay_blocks(sys, hTar);
cascaded_delay_info = remove_noncascaded_blocks(delay_blocks);
cascade_heads       = find_cascade_heads(cascaded_delay_info);
for i=1:length(cascade_heads),
  replace_cascade_chain(cascade_heads(i).src_blk, hTar);
end


% ---------------------------------------------------------------------
function full_list = find_all_delay_blocks(sys, hTar)
% Generate list of candidate delay blocks

delays = hTar.delays;
delays = delays(ishandle(delays));
full_list = [];
if ~isempty(delays),
    full_list = getfullname(delays);
    if ~iscell(full_list),
        full_list = {full_list};
    end
end


% ---------------------------------------------------------------------
function cascaded_delay_info = remove_noncascaded_blocks(all_delay_blocks)
% Loop through all blocks
% Keep those blocks that have only one destination, and
%   the destination is another delay block in the list.
%
cascaded_delay_info = [];

for i=1:length(all_delay_blocks),
   this_blk = all_delay_blocks{i};
   dest_blk = block_has_one_dest(this_blk);
   
   if ~isempty(dest_blk),
      % Verify that dest block is in delay list, and the block
      % is not forming a self-loop
      match_idx = strmatch(dest_blk, all_delay_blocks, 'exact');
      if ~isempty(match_idx) & ~strcmp(dest_blk, this_blk),
         % Found a block that cascades into another delay:
         cascaded_delay_info(end+1).src_blk = this_blk;
         cascaded_delay_info(end).dst_blk = dest_blk;
      end
   end
end


% ---------------------------------------------------------------------
function cascade_heads = find_cascade_heads(head_list)
% List of "head" indices
% The index of the first block in each cascade will be retained
% If a later block is found to cascade into one of the head blocks,
% the old (erroneous) head block will be replaced by this new
% (more correct) head block index.  Thus, we iterate until all
% blocks have been visited.

cascade_heads = [];
if length(head_list)<1, return; end

all_dest_names = {head_list.dst_blk};

% All entries in head_list are assumed to be a
% true head of a cascade chain until proven otherwise:
head_list_idx = 1:length(head_list);
j=1;

while j <= length(head_list_idx),
   % See if any other "heads" point to j'th head block
   idx = strmatch( head_list(head_list_idx(j)).src_blk, ...
                   all_dest_names, 'exact');
   
   if ~isempty(idx),
      % Another head block points to this delay
      % This block is not the head of a cascade-chain
      % Remove it from the list
      head_list_idx(j)=[];
      
      % If you want to know which block is pointing to this (the j'th)
      % block, it's: head_list(all_others_idx(idx))
   else
      % No other blocks are pointing to this one -- it's really a
      % head of a cascade chain.  This block is: head_list(head_list_idx(j))
      % set_param(head_list(head_list_idx(j)).src_blk,'backgroundcolor','red')
      % pause(1)
      % set_param(head_list(head_list_idx(j)).src_blk,'backgroundcolor','white')
      j=j+1;
   end
end

cascade_heads = head_list(head_list_idx);


% ---------------------------------------------------------------------
function replace_cascade_chain(head_blk, hTar)

[chain, total_delay] = get_delay_chain_list(head_blk, hTar);

% Store head block parameters:
%
% Store position and orientation of head block
pos = get_param(chain(1).blk, 'Position');
orient = get_param(chain(1).blk, 'Orientation');
% Store output port descriptor of block driving head block
head_conn = get_param(chain(1).blk,'PortConnectivity');
% Store input port descriptor of block driven by tail block
tail_conn = get_param(chain(end).blk,'PortConnectivity');

% Delete all blocks in chain, including in/out connections:
for i=1:length(chain),
   full_blk = chain(i).blk;
   deleteio(hTar, full_blk);
   delete_block(full_blk);
end

% Add a delay block with new latency
idx = findstr(head_blk, '/');
blkname = head_blk;
if ~isempty(idx),
    blkname = head_blk(idx(end)+1:end);
end
delay(hTar, blkname, num2str(str2num(total_delay)));
set_param(head_blk, 'Position', pos, ...
   'Orientation', orient, ...
   'ShowName','off');

% Add connection lines for input and output ports
add_io(head_blk,head_conn,tail_conn);


% ---------------------------------------------------------------------
%                   UTILITY FUNCTIONS
% ---------------------------------------------------------------------
function add_io(full_blk, head_conn, tail_conn)
% Add connection lines for input and output ports

[parent,blk] = fileparts(full_blk);

% Add input port connection:
dst = [blk '/1'];
for i=1:length(head_conn),
   ci = head_conn(i);
   if ~isempty(ci.SrcBlock),
      % It's the src connection:
      % Only one source driving this port
      src = getfullname(ci.SrcBlock);
      [dummy,src]=fileparts(src);
      src = [src '/' int2str(ci.SrcPort+1)];
      add_line(parent,src,dst,'autorouting','on');
      
      break; % can only be one src port on a delay block
   end
end

% Add output port connections:
src = [blk '/1'];
for i=1:length(tail_conn),
   ci = tail_conn(i);
   if isempty(ci.SrcBlock),
      % It's a dest connection
      % Could be multiple destinations!
      for j=1:length(ci.DstBlock),
         dst = getfullname(ci.DstBlock(j));
         [dummy,dst]=fileparts(dst);
         dst = [dst '/' int2str(ci.DstPort(j)+1)];
         add_line(parent,src,dst,'autorouting','on');
      end
      
      break; % can only be one dst port on a delay block
   end
end


% ---------------------------------------------------------------------
function [chain, total_delay] = get_delay_chain_list(head_blk, hTar)

chain = [];
delay = 0;
total_delay = '';
dest_blk = head_blk;

while ~isempty(delay),
   delay = getDelay(dest_blk,hTar);
   if ~isempty(delay),
      chain(end+1).blk = dest_blk; % string path
      chain(end).delay = delay;    % string expression
      
      % Construct an evaluatable string expression
      % Make no attempt to evaluate the value directly,
      % since string might require eval in parent mask
      % workspace, etc.
      if isempty(total_delay),
          total_delay = delay;
      else
          total_delay = [total_delay '+' delay];
      end
      
      dest_blk = block_has_one_dest(dest_blk);
   end
end


% ---------------------------------------------------------------------
function delay = getDelay(blk,hTar)

% Returns empty string if block is not a known delay block
% Returns a STRING corresponding to the delay value if
% it is a delay block.  We do not attempt to evaluate the
% expression, since evaluation might only be possible in the
% context of the parent workspace.

delay = '';


% Supports an empty block name
if isempty(blk), return; end

try
    delay = getdelaylatency(hTar, blk);
catch
    % No op: block is not a delay
end
    

% ---------------------------------------------------------------------
function dstBlock = block_has_one_dest(blk)
% BLOCK_HAS_ONE_DEST
%
% Returns name of destination block if output port has exactly
% one destination.  If multiple output ports exist, only the
% first destination port found in connectivity list is checked.
% An empty string is returned otherwise.
%
% Note that an unconnected output port or an output port with
%   more than one destination forces fails the test and returns
%   an empty string.

conn = get_param(blk, 'portconnectivity');
dstBlock = '';

for i=1:length(conn),
   % Check if this is the output (Dst) port connection entry:
   %
   % NOTE:
   %  If this is a source port, then the SrcBlock entry is never empty.
   %  If it is an unconnected source, it is set to -1.
   %  However, unconnected dest ports leave DstBlock empty (1x0), so
   %  it is harder to check if the dest is "unconnected" versus "not
   %  a dest port".
   if isempty(conn(i).SrcBlock),  % is this a dest port?
      if length(conn(i).DstPort) == 1,
         dstBlock = getfullname(conn(i).DstBlock);
      end
      return
   end
end


% [EOF] 

function varargout = deleteio(hTar, full_blk)
%DELETEIO Delete connections of the block specified by full_blk
%    [SRC, DSTS, CONN] = DELETEIO(...) returns the source, the
%    destinations and the connectivity information of the destination
%    blocks. 

%    This should be a private method

%    Copyright 1995-2004 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:49:24 $

[parent, blk] = fileparts(full_blk);
conn = get_param(full_blk, 'portconnectivity');
connpos = [];

full_srcblk = '';
for i=1:length(conn),
    
    % Delete connection to the source block
    full_src = delete_i(parent, blk, conn(i));
    
    % Delete connection to the destination blocks
    full_dst = delete_o(parent, blk, conn(i));
    
    % Save connectivity information
    if ~isempty(full_src),
        full_srcblk = full_src;
    end
    if ~isempty(full_dst),
        full_dstblk = full_dst;
        connpos = [connpos, conn(i)];
    end
    
end

% Parse Outputs
if nargout>0, varargout{1} = full_srcblk; end
if nargout>1, varargout{2} = full_dstblk; end
if nargout>2, varargout{3} = connpos; end
 

% ---------------------------------------------------------------------
function full_src = delete_i(parent, blk, ci)

full_src = [];

if ~isempty(ci.SrcBlock),
    if ci.SrcBlock ~= -1,
        full_src = getfullname(ci.SrcBlock);
        [dummy,src] = fileparts(full_src);
        src = [src '/' int2str(ci.SrcPort+1)];
        delete_line(parent, src, [blk '/' ci.Type]);
        
        % if SrcBlock == -1, this is an unconnected source port
    end
end


% ---------------------------------------------------------------------
function full_dst = delete_o(parent, blk ,ci)
 
full_dst = [];

if ~isempty(ci.DstBlock),
    if ci.DstBlock ~= -1,
        dstblk = ci.DstBlock;
        dstport = ci.DstPort;
        if ~isempty(dstblk),
            for j=1:length(dstblk),
                full_dst{j} = getfullname(dstblk(j));
                [dummy,dst] = fileparts(full_dst{j});
                dst = [dst '/' int2str(dstport(j)+1)];
                delete_line(parent, [blk '/1'], dst);
            end
        end
    end
end

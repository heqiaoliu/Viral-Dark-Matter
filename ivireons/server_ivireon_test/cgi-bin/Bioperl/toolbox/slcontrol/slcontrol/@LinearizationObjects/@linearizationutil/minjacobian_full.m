function [J_sp,J_iter] = minjacobian_full(this,J_iter,opt) 
% MINJACOBIAN_FULL  Perform the full block reduction.
%
 
% Author(s): John W. Glass 10-Aug-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/31 07:34:40 $

% Perform block reduction if requested
if strcmp(opt.BlockReduction,'on')
    J_fp = minjacobian_firstpass(linutil,J_iter);
    J_sp = minjacobian_secondpass(linutil,J_fp);
    % Store the blocks that were in the path after the block reduction
    for ct = numel(J_iter.Mi.BlocksInPath):-1:1
        BlocksInPath(ct) = any(J_iter.Mi.BlockHandles(ct) == J_sp.Mi.BlockHandles); %#ok<AGROW>
    end
    % Store the reduced blocks in path
    J_iter.Mi.BlocksInPath = BlocksInPath;
else
    J_sp = J_iter;
end

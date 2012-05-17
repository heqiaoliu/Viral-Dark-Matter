function [mb,nb] = bestblk(siz,k)
%BESTBLK Optimal block size for block processing.
%   SIZ = BESTBLK([M N],K) returns, for an M-by-N image, the
%   optimal block size for block processing. K is a scalar
%   specifying the maximum row and column dimensions for the
%   block; if the argument is omitted, it defaults to 100. SIZ is
%   a 1-by-2 vector containing row and column dimensions for the
%   block.
%
%   [MB,NB] = BESTBLK([M N],K) returns the row and column
%   dimensions in MB and NB, respectively.
%
%   Example
%   -------
%       siz = bestblk([640 800], 72)
%
%   See also BLOCKPROC.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 5.15.4.4 $  $Date: 2009/04/15 23:10:24 $

if nargin==1, k = 100; end % Default block size

%
% Find possible factors of siz that make good blocks
%

% Define acceptable block sizes
m = floor(k):-1:floor(min(ceil(siz(1)/10),ceil(k/2)));
n = floor(k):-1:floor(min(ceil(siz(2)/10),ceil(k/2)));

% Choose that largest acceptable block that has the minimum padding.
[~,ndx] = min(ceil(siz(1)./m).*m-siz(1)); blk(1) = m(ndx);
[~,ndx] = min(ceil(siz(2)./n).*n-siz(2)); blk(2) = n(ndx);

if nargout == 2,
    mb = blk(1);
    nb = blk(2);
else
    mb = blk;
end

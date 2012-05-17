function x = gop(F,x, labTarget)
%GOP   Global operation
%   RES = GOP(FUN,X) is the reduction via the function handle FUN of
%   the variant arrays X from each lab. The result is replicated on all labs.
%   The function Z=FUN(X,Y) should accept two arguments X and Y of the same
%   type and produce a result Z of that type, so it can be used
%   iteratively, i.e.  F(F(x1,x2),F(x3,x4)).
%
%   RES = GOP(FUN, X, LABTARGET) reduces the variant arrays X using FUN,
%   and places the result on the lab indicated by LABTARGET.  RES will be
%   equal to [] on all other labs.
%
%   Example
%   spmd
%     x = labindex;
%     gop(@plus,x)    % the sum of the x's from each lab, same as gplus(x)
%     gop(@max,x)     % the max of the x's from each lab.
%     gop(@horzcat,x) % the horizontal concatenation of the x's.
%   end
%
%   See also GPLUS, GCAT.

%   Copyright 2005-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2010/02/25 08:02:14 $

% Binary tree reduction to root at node labTarget.
error(nargchk(2, 3, nargin, 'struct'));

if ~isa(F,'function_handle')
    error('distcomp:gop:funHandle','First input must be a function handle.');
end

if isdistributed(x)
    error('distcomp:gop:distributed','Second input must not be a distributed array.');
end
if isa(x, 'codistributed')
    error('distcomp:gop:codistributed','Second input must not be a codistributed array.');
end

if nargin == 2
    %no target given
    bTarget = false;
    labTarget = 1;
else
    if ~distributedutil.CodistParser.isValidLabindex(labTarget)
        error('distcomp:gop:incorrectLabIndex', ...
              'labTarget must be an integer between 1 and numlabs.');
    end
    bTarget = true;
end

mwTag1 = 32442;
mwTag2 = 32443;

n = numlabs;
curLab = labindex;
treeHeight = 1;  % Height of tree

seenError = false;

while treeHeight < n
    % everything to the left of target lab.  Data is always sent to the
    % right.
    if (curLab < labTarget)
        if mod(labTarget-curLab - 1 ,2*treeHeight) == treeHeight
            %Make sure the lab we send from is of the right modulus
            labSend(x, curLab + treeHeight, mwTag1);
        elseif mod(labTarget-curLab - 1,2*treeHeight) == 0 && curLab-treeHeight >= 1
            %Make sure the lab we would try to receive on exists, by
            % checking curLab-treeHeight >= 1
            receiveWithErrorHandling(-treeHeight);
        end
    else
        % everything to the right of target lab, including itself
        if mod(curLab - labTarget,2*treeHeight) == treeHeight
            %Make sure the lab we send from is of the right modulus
            labSend(x, curLab - treeHeight, mwTag1);
        elseif mod(curLab-labTarget,2*treeHeight) == 0 && curLab+treeHeight <= n
            %Make sure the lab we would try to receive on exists, by
            %curLab+treeHeight <= n
            receiveWithErrorHandling(treeHeight);
        end
    end
    treeHeight = 2*treeHeight;
end

%At the end if target lab was not 1, need to send everything from the
%left over to the right.
if curLab == labTarget - 1
    labSend(x, labTarget, mwTag1);
elseif curLab == labTarget && labTarget > 1
    receiveWithErrorHandling(-1);
end

    function receiveWithErrorHandling(direction)
        y = labReceive(curLab + direction, mwTag1);
        seenNow = false;
        % This test takes around 6 microseconds
        if isa( y, 'goperror' )
            seenNow = true;
        end
        % This ensures that we latch into the error state.
        if seenNow && ~seenError
            % Someone has just sent us an error, so send that on
            x = y;
            seenError = true;
        end
        if ~seenError
            try
                if (direction < 0)
                    x = F(y,x);
                else
                    x = F(x,y);
                end
            catch err
                % If we caught an error, we need to propagate the error up the tree
                x   = goperror( err );
                seenError = true;
            end
        else
            % The first time we were sent an error, we stored it in "x", so we don't need to
            % set "x" here.
        end
    end

% Starting at node 1, send result to all nodes.
% Use the tag that we now have, as that will indicate whether
% we are sending a result or an error.
if (~bTarget)
    treeHeight = treeHeight/2;
    while treeHeight >= 1;
        if mod(curLab-1,2*treeHeight) == 0 && curLab+treeHeight <= n
            labSend(x,curLab+treeHeight,mwTag2);
        elseif mod(curLab-1,2*treeHeight) == treeHeight
            x = labReceive(curLab-treeHeight, mwTag2);
        end
        treeHeight = treeHeight/2;
    end
else
    if curLab ~= labTarget
        x = [];
    end
end

if isa( x, 'goperror' )
    % We were sent an error rather than a result
    throw( getError( x ) );
end
end

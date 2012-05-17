function result = iscatastrophic(trellis)
%ISCATASTROPHIC  Determine if a convolutional code is catastrophic or not
%   RESULT = ISCATASTROPHIC(TRELLIS) returns logical true (1) if the 
%   specified trellis corresponds to a catastrophic convolutional code 
%   and logical false (0) otherwise.
%
%   See also ISTRELLIS, POLY2TRELLIS.

%   Reference:   Stephen B. Wicker, "Error Control Systems for Digital
%   Communication and Storage", Prentice-Hall, 1995, pp. 274-275.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/27 20:09:28 $

%
% Check for correct number of input and output arguments
%
error(nargchk(1,1,nargin,'struct'));
error(nargoutchk(0,1,nargout,'struct'));

%
% Check that the input is a valid trellis
%
if ~istrellis(trellis),
    error('comm:iscatastrophic:invalidTrellis', ...
           ['The input to ISCATASTROPHIC must be a valid trellis. ' ...
            'See ISTRELLIS for more information.']);  
end

result = false;

% Find the zero-weight paths in the trellis
[idx,jdx] = find(trellis.outputs==0);

% Compute the connectivity matrix (conmat) for the zero-weight transitions
% in the trellis, excluding the transition from state 1 to itself.  Hence,
% the reason the for loop starts at 2.
conmat = sparse(trellis.numStates,trellis.numStates);
for k = 2:numel(idx)
    conmat(idx(k),trellis.nextStates(idx(k),jdx(k))+1)=1;
end

% Now look for zero weight loops in the trellis.  Squaring the
% connectivity matrix produces the paths of length 2, raising it to the
% third power produces the paths of length three, etc.  
test = conmat;
for k1 = 1:trellis.numStates,
    % It is sufficient to consider only paths of length k1, up to the 
    % number of states in the trellis.  (Paths longer than the number of 
    % states must contain repeated states, and hence loops that have length
    % less than or equal to the number of states.)

    % If there are any diagonal elements, that means there is a path
    % that starts in state and ends in state k2, in other words, a loop.
    % Since we are only examining the connectivity for zero weight
    % paths, if we find a loop it is a zero weight loop, hence the
    % code is catastrophic.
    result = full(any(diag(test)==1));
    
    if result==true
        break
    else
        test = test*conmat;
    end
end
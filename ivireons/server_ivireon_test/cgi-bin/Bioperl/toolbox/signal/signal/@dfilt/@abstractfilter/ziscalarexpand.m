function S = ziscalarexpand(Hm,S)
%ZISCALAREXPAND Expand empty or scalar initial conditions to a vector.

% This should be a private method

%   Author: V. Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.6.4.6 $  $Date: 2009/03/30 23:59:41 $

error(nargchk(2,2,nargin,'struct'));

if ~isnumeric(S)
  error(generatemsgid('MustBeNumeric'),'States must be numeric.');
end
if issparse(S),
    error(generatemsgid('Sparse'),'States cannot be a sparse matrix.');
end

numstates = nstates(Hm);
% dss start
% if (numstates==0 && ~isempty(S)) 
%     disp('here')
%     error(generatemsgid('NotSupported'),'Filter coefficients not defined. States not set.');
% end
% dss end
if numstates,
    if isempty(S),
        S=0;
    end
    if length(S)==1,
        % Zi expanded to a vector of length equal to the number of states
        S = S*ones(numstates,1);
    end
    
    % Transpose if row vector only
    if find(size(S)==1),
        S = S(:);
    end
    
    % At this point we must have a vector or matrix with the right number of
    % rows
    if size(S,1) ~= numstates,
        error(generatemsgid('InvalidDimensions'),...
            'The states must be a vector or matrix with %d rows and one column per channel.',numstates);
    end
elseif ~isempty(S),
    
    % This handles the case where one of the dimensions is zero.
    error(generatemsgid('DFILTErr'),'The states must be empty when there are no coefficients.');
end

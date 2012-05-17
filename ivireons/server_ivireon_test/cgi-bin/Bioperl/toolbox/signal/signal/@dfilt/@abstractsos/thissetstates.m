function S = thissetstates(Hd,S)
%THISSETSTATES Overloaded set for the States property.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/03/30 23:59:42 $

if ~isempty(S),
    % Check data type, quantize if needed
    S = validatestates(Hd.filterquantizer, S);
    nsections = Hd.nsections;
    if rem(size(S,2), nsections)~=0,
        error(generatemsgid('InvalidDimensions'),'The number of columns of the state matrix must be a multiple of %d.',nsections);
    end
	% Reshape to one column per channel	
	ns = 2*nsections;
    w=warning('off');
	ncols = prod(size(S))/ns; %#ok<PSIZE> numel doesn't work as expected in fixed point
    warning(w);
	S = reshape(S,ns,ncols);
end
Hd.hiddenstates = S;

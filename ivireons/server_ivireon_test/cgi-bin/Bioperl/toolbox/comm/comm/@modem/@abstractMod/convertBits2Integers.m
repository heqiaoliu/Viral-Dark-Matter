function y = convertBits2Integers(h, x)
%CONVERTBITS2INTEGERS Convert bits/binary words stored in X to integers/symbols. 

% @modem/@abstractmod

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/31 02:45:38 $

nbits = log2(h.M);
pow2vector = 2.^(0:1:(nbits-1));
sizeX = size(x);
x = reshape(x, nbits, numel(x)/nbits)';

x = x(:, nbits:-1:1);
y = x(:,1:nbits)*pow2vector(:,1:nbits).';
y = reshape(y, sizeX(1)/nbits, sizeX(2));

%--------------------------------------------------------------------
% [EOF]
    
        
        
        
        
        

        
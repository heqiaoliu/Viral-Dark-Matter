function type = algType(h,N,K,short,puncs)
% ALGTYPE Set the Type string for the Algebraic encoder
%
%   Inputs:
%     h: Encoder/Decoder object
%     N: Code length
%     K: Message Length
%     Short: Shortening Length
%     Puncs: Puncture Vector

% @fec\@rsenc

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:41 $

if(h.nSet && h.kSet)

    numPuncs = sum(~puncs);

    actN = N - short - numPuncs;
    actK = K - short;

    %Basic string
    if(actN == N  && actK == K)
        type = ['(', num2str(actN), ',' ,num2str(actK), ') Reed-Solomon Encoder'];
        return
    end

    if(short > 0 && numPuncs == 0)
        type = ['Shortened (', num2str(actN), ',' ,num2str(actK), ') Reed-Solomon Encoder'];
    elseif (short == 0 && numPuncs > 0)
        type = ['Punctured (', num2str(actN), ',' ,num2str(actK), ') Reed-Solmon Encoder'];
    else
        type = ['Shortened, Punctured (', num2str(actN), ',' ,num2str(actK), ') Reed-Solmon Encoder'];
    end
else 
    type = '';
end

function type = algType(h,N,K,short,puncs)
% ALGTYPE Set the Type string for the Algebraic encoder
%
%   Inputs:
%     h: Encoder/Decoder object
%     N: Code length
%     K: Message Length
%     Short: Shortening Length
%     Puncs: Puncture Vector

% @fec\@rsdec

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:58:39 $

if(h.nSet && h.kSet)

    numPuncs = sum(~puncs);

    actN = N - short - numPuncs;
    actK = K - short;

    %Basic string
    if(actN == N  && actK == K)
        type = ['(', num2str(actN), ',' ,num2str(actK), ') Reed-Solomon Decoder'];
        return
    end

    if(short > 0 && numPuncs == 0)
        type = ['Shortened (', num2str(actN), ',' ,num2str(actK), ') Reed-Solomon Decoder'];
    elseif (short == 0 && numPuncs > 0)
        type = ['Punctured (', num2str(actN), ',' ,num2str(actK), ') Reed-Solmon Decoder'];
    else
        type = ['Shortened, Punctured (', num2str(actN), ',' ,num2str(actK), ') Reed-Solmon Decoder'];
    end

else
    type = '';
end

function out = findcolumnletter(h,value)
% FINDCOLUMNLETTER looks for column letter corresponding to an index

% input: index in integer, starting from 1
% output: corresponding string, starting from A, otherwise an empty string

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.

if isempty(value) || (~isnumeric(value)) || ((value-floor(value))~=0) || value<=0
    out='';
else
    CN = value;
    N = 0;
    Ns = 0;
    while CN > Ns
        N = N + 1;
        Ns = Ns + 26 ^ N;
    end
    CL = '';
    for c = 1:N
        S = 0;
        for e = 0:c - 1
            S = S + 26 ^ e;
        end
        CL = strcat(char(mod(floor((CN - S)/(26^(c-1))),26)+65),CL);
    end
    out = CL;
end
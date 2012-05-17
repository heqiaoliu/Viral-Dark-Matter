function out = findcolumnnumber(h,value)
% FINDCOLUMNNUMBER looks for index corresponding to a column letter

% input: string, starting from A 
% output: corresponding absolute index in integer, starting from 1,
% otherwise empty

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.

if ~ischar(value) || isempty(value)
    out=[];
else
    tmp=upper(value);
    out=0;
    for i=1:length(tmp)
        if tmp(end-i+1)<'A' || tmp(end-i+1)>'Z'
            out=[];
            return
        end
        out=out+(tmp(end-i+1)-'A'+1)*(26^(i-1));
    end
end
function strout = tsParseBufferStr(tsname,varargin)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

strout = '';
for k=1:length(varargin)
    if ischar(varargin{k})
        strout = [strout, varargin{k}];
    elseif isnumeric(varargin{k})
        if isscalar(varargin{k}) && round(varargin{k})==varargin{k}
            strout = [strout sprintf('%d',varargin{k})];
        elseif isscalar(varargin{k}) && round(varargin{k})~=varargin{k}
            strout = [strout sprintf('%f',varargin{k})];
        else
            strout = [strout '['  num2str(varargin{k}) ']'];
        end
    end
end

strout = strrep(strout,'#',tsname);
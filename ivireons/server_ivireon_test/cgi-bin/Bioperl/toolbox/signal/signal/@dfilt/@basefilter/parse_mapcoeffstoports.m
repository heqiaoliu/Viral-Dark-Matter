function [out idx] = parse_mapcoeffstoports(~,varargin)
%PARSE_MAPCOEFFSTOPORTS 

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/14 04:00:52 $

out = 'off';
idx = find(strcmpi(varargin,'MapCoeffsToPorts'));
if isempty(idx) || strcmpi(varargin{idx+1},'off'),
   if ~isempty(find(strcmpi(varargin,'CoeffNames'), 1)),
       error(generatemsgid('InvalidParameter'), ...
           'The MapCoeffsToPorts property must be ''on'' for the CoeffNames property to apply.');
   end
else
    out = varargin{idx+1}; 
    if strcmpi(out,'on'),
        idx2 = find(strcmpi(varargin,'Link2Obj'));
        if ~isempty(idx2) && strcmpi(varargin{idx2+1},'on')
            error(generatemsgid('InvalidParameter'), ...
                'The Link2Obj and MapCoeffsToPorts properties cannot be ''on'' simultaneously.');
        end
    end
end

% [EOF]

function hPrm = super_construct(hObj, varargin)
%SUPER_CONSTRUCT Check the inputs

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:13 $

% We return the parameters so subclasses can determine which ones they want
% to keep.  They only keep the ones they use, not all that are passed in.
hPrm = [];

for i = 1:length(varargin)
    
    % Look for a parameter object in the input
    if isa(varargin{i}, 'sigdatatypes.parameter'),
        if isempty(hPrm),
            hPrm = varargin{i};
        else
            hPrm = [hPrm; varargin{i}];
        end
    end
end

% Make sure there are no copies of the same parameter.
hPrm = unique(hPrm);

% [EOF]

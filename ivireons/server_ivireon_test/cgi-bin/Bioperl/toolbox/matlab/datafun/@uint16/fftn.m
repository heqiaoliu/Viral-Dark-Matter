function y = fftn(varargin)
%FFTN Overloaded function for UINT16 input.

%   $Revision: 1.1.6.3 $  $Date: 2007/09/18 02:15:43 $
%   Copyright 1984-2007 The MathWorks, Inc. 

for k = 1:length(varargin)
    if (isa(varargin{k},'uint16'))
        varargin{k} = double(varargin{k});
    end
end

y = fftn(varargin{:});

function f = fimath2use(varargin)
%FIMATH2USE Determine which FIMATH to use.
%   This should be a private method.


%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/24 19:04:13 $

b = cellfun(@isfimathlocal,varargin);

if ~any(b),
    f = fimath;
else
    idx = find(b,1,'first');
    f = varargin{idx}.fimath;        
    inputsWithFiMath = varargin(b);
    
    for k = 1:length(inputsWithFiMath),
        if ~isequal(inputsWithFiMath{k}.fimath,f)
            error('fi:fimath2use:fimathConflict', ...
                'The local fimaths do not match.');
        end
    end
end
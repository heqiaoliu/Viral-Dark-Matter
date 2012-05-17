function valid = isprop(varargin)
%ISPROP Returns true if the property exists.
%   ISPROP(H, PROP) Returns true if PROP is a property of H.  This function
%   tests for Handle objects and Handle Graphics objects.

%   Copyright 1988-2008 The MathWorks, Inc.

try
    switch nargin
    case 2
        % ISPROP for hg or handle object instances
        if (isempty(varargin{1}))
            valid = false;
            return;
        end

        valid = false(size(varargin{1}));
        for i = 1:numel(varargin{1})
            p=findprop(handle(varargin{1}(i)), varargin{2});
            valid(i) = ~isempty(p) && strcmpi(p.Name,varargin{2});
        end
    case 3
        % ISPROP for class - package and class name
        p=findprop(findclass(findpackage(varargin{1}),varargin{2}),varargin{3});
        valid = ~isempty(p) && strcmpi(p.Name,varargin{3});
    otherwise
        valid = false;
    end
catch e %#ok<NASGU>
    valid = false;
end

function [xx,yy,zz] = meshgrid(x,y,z)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
if nargout<3, % 2-D array case
    if nargin == 1
        y = x;
    end
    if isempty(x) || isempty(y)
        xx = eml_expand(eml_scalar_eg(x),[0,0]);
        yy = eml_expand(eml_scalar_eg(y),[0,0]);
    else
        xx = repmat(x(:).',[eml_numel(y) 1]);
        yy = repmat(y(:),[1 eml_numel(x)]);
    end
else  % 3-D array case
    if nargin == 1
        y = x;
        z = x;
    end
    eml_assert(nargin ~= 2, 'Not enough input arguments.');
    if isempty(x) || isempty(y) || isempty(z)
        xx = eml_expand(eml_scalar_eg(x),[0,0]);
        yy = eml_expand(eml_scalar_eg(y),[0,0]);
        zz = eml_expand(eml_scalar_eg(z),[0,0]);
    else
        nx = eml_numel(x); ny = eml_numel(y); nz = eml_numel(z);
        xx = repmat(x(:).',[ny 1 nz]);
        yy = repmat(y(:),[1 nx nz]);
        zz = repmat(reshape(z,[1 1 nz]),[ny nx 1]);
    end
end

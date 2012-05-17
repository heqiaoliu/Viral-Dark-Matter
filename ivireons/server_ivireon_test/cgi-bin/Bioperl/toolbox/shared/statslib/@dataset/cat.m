function a = cat(dim,varargin)
%CAT Concatenate dataset arrays.
%   DS = CAT(DIM, DS1, DS2, ...) concatenates the dataset arrays DS1, DS2,
%   ... along dimension DIM by calling the @DATASET/HORZCAT or
%   @DATASET/VERTCAT method. DIM must be 1 or 2.
%
%   See also DATASET/HORZCAT, DATASET/VERTCAT.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 22:37:39 $

if dim == 1
    a = vertcat(varargin{:});
elseif dim == 2
    a = horzcat(varargin{:});
else
    error('stats:dataset:cat:InvalidDim', ...
          'DIM must be 1 or 2 for a 2-D dataset array.');
end

function Y = reshape(this,varargin)
%RESHAPE Reshape array 
%   Refer to the MATLAB RESHAPE reference page for more information. 
%
%   See also RESHAPE 

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/12/10 21:33:09 $

error(nargchk(2,inf,nargin,'struct'));

if nargin==2
  newsize = varargin{1};
else
  newsize = ones(1,length(varargin));
  nUnknownDims = 0;
  for k=1:length(varargin)
    if isscalar(varargin{k})
      newsize(k) = varargin{k};
    elseif isempty(varargin{k})
      nUnknownDims = nUnknownDims + 1;
      if nUnknownDims>1
        error('fi:reshape:unknownDim',...
              'Size can only have one unknown dimension.');
      end
      uknownIndex = k;
    else
      error('fi:reshape:notRealInt',...
            'Size arguments must be integer scalars.');
    end
  end

  % Fill in the missing dimension, if there is one
  if nUnknownDims>0
    prodKnownDim = prod(double(newsize));
    unknownDim = numberofelements(this)/prodKnownDim;
    if fix(unknownDim) ~= unknownDim
      error('fi:reshape:dimsNotDivisible',...
            ['Product of known dimensions, %d, ',...
             'not divisible into total number of elements, %d.'],...
            prodKnownDim, numberofelements(this));
    end
    newsize(uknownIndex) = unknownDim;
  end
end

% Validate the size vector
if length(newsize)==1
  error('fi:reshape:sizeIsScalar',...
        'Size vector must have at least two elements.');
end
if ~isvector(newsize)
  error('fi:reshape:sizeNotVector',...
        'Size vector must be a row vector with integer elements.');
end
if ~all(newsize>=0)
  error('fi:reshape:sizeIsNegative',...
        'Size vector elements should be nonnegative.');
end
if prod(double(newsize))~=numberofelements(this)
  error('fi:reshape:notSameNumel',...
        'To RESHAPE the number of elements must not change.');
end

% Remove any trailing N-D singleton dimensions
if length(newsize)>2
  ntrailing_singletons = 0;
  for k=length(newsize):-1:3
    if newsize(k)~=1
      break
    end
    ntrailing_singletons = ntrailing_singletons + 1;
  end
  newsize((end-ntrailing_singletons+1):end) = [];
end

Y = fi_reshape(this,newsize);

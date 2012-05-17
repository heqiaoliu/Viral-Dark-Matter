function c = conv(a, b, shape)
%CONV Convolution and polynomial multiplication.
%   C = CONV(A, B) convolves vectors A and B.  The resulting vector is
%   length MAX([LENGTH(A)+LENGTH(B)-1,LENGTH(A),LENGTH(B)]). If A and B are
%   vectors of polynomial coefficients, convolving them is equivalent to
%   multiplying the two polynomials.
%
%   C = CONV(A, B, SHAPE) returns a subsection of the convolution with size
%   specified by SHAPE:
%     'full'  - (default) returns the full convolution,
%     'same'  - returns the central part of the convolution
%               that is the same size as A.
%     'valid' - returns only those parts of the convolution 
%               that are computed without the zero-padded edges. 
%               LENGTH(C)is MAX(LENGTH(A)-MAX(0,LENGTH(B)-1),0).
%
%   Class support for inputs A,B: 
%      float: double, single
%
%   See also DECONV, CONV2, CONVN, FILTER and, 
%   in the Signal Processing Toolbox, XCORR, CONVMTX.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 5.16.4.7 $  $Date: 2008/10/31 06:19:46 $

if ~isvector(a) || ~isvector(b)
  error('MATLAB:conv:AorBNotVector', 'A and B must be vectors.');
end

if nargin < 3
    shape = 'full';
end

if ~ischar(shape)
  error('MATLAB:conv:unknownShapeParameter', ...
        'SHAPE must be ''full'', ''same'', or ''valid''.');
end

% compute as if both inputs are column vectors
c = conv2(a(:),b(:),shape);

% restore orientation
if strcmp(shape,'full')
    if length(a) > length(b)
        if size(a,1) == 1 %row vector
            c = c.';
        end
    else
        if size(b,1) == 1 %row vector
            c = c.';
        end
    end
else
    if size(a,1) == 1 %row vector
        c = c.';
    end
end

    
    
    

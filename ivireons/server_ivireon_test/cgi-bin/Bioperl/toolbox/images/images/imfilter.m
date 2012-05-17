function b = imfilter(varargin)
%IMFILTER N-D filtering of multidimensional images.
%   B = IMFILTER(A,H) filters the multidimensional array A with the
%   multidimensional filter H.  A can be logical or it can be a 
%   nonsparse numeric array of any class and dimension.  The result, 
%   B, has the same size and class as A.
%
%   Each element of the output, B, is computed using double-precision
%   floating point.  If A is an integer or logical array, then output 
%   elements that exceed the range of the given type are truncated, 
%   and fractional values are rounded.
%
%   B = IMFILTER(A,H,OPTION1,OPTION2,...) performs multidimensional
%   filtering according to the specified options.  Option arguments can
%   have the following values:
%
%   - Boundary options
%
%       X            Input array values outside the bounds of the array
%                    are implicitly assumed to have the value X.  When no
%                    boundary option is specified, IMFILTER uses X = 0.
%
%       'symmetric'  Input array values outside the bounds of the array
%                    are computed by mirror-reflecting the array across
%                    the array border.
%
%       'replicate'  Input array values outside the bounds of the array
%                    are assumed to equal the nearest array border
%                    value.
%
%       'circular'   Input array values outside the bounds of the array
%                    are computed by implicitly assuming the input array
%                    is periodic.
%
%   - Output size options
%     (Output size options for IMFILTER are analogous to the SHAPE option
%     in the functions CONV2 and FILTER2.)
%
%       'same'       The output array is the same size as the input
%                    array.  This is the default behavior when no output
%                    size options are specified.
%
%       'full'       The output array is the full filtered result, and so
%                    is larger than the input array.
%
%   - Correlation and convolution
%
%       'corr'       IMFILTER performs multidimensional filtering using
%                    correlation, which is the same way that FILTER2
%                    performs filtering.  When no correlation or
%                    convolution option is specified, IMFILTER uses
%                    correlation.
%
%       'conv'       IMFILTER performs multidimensional filtering using
%                    convolution.
%
%   Notes
%   -----
%   IMFILTER may take advantage of the Intel Performance Primitives Library
%   (IPPL), thus accelerating its execution time. IPPL is activated only if
%   A and H are both two dimensional and A is uint8, uint16, int16, single,
%   or double.
%
%   When IPPL is used, imfilter has different rounding behavior on some
%   processors.  Normally, when A is an integer class, filter outputs such
%   as 1.5, 4.5, etc., are rounded away from zero.  However, when IPPL is
%   used, these values are rounded toward zero.  This behavior may change
%   in a future release.
%
%   To disable IPPL, use this command:
%
%       iptsetpref('UseIPPL',false)
%
%   Example 
%   -------------
%       originalRGB = imread('peppers.png'); 
%       h = fspecial('motion',50,45); 
%       filteredRGB = imfilter(originalRGB,h); 
%       figure, imshow(originalRGB), figure, imshow(filteredRGB)
%       boundaryReplicateRGB = imfilter(originalRGB,h,'replicate'); 
%       figure, imshow(boundaryReplicateRGB)
%
%   See also FSPECIAL, CONV2, CONVN, FILTER2, IPPL. 

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.9.4.14 $  $Date: 2009/12/28 04:16:39 $

% Testing notes
% Syntaxes
% --------
% B = imfilter(A,H)
% B = imfilter(A,H,Option1, Option2,...)
%
% A:       numeric, full, N-D array.  May not be uint64 or int64 class. 
%          May be empty. May contain Infs and Nans. May be complex. Required.
%         
% H:       double, full, N-D array.  May be empty. May contain Infs and Nans.
%          May be complex. Required.
%
% A and H are not required to have the same number of dimensions. 
%
% OptionN  string or a scalar number. Not case sensitive. Optional.  An
%          error if not recognized.  While there may be up to three options
%          specified, this is left unchecked and the last option specified
%          is used.  Conflicting or inconsistent options are not checked.
%
%        A choice between these options for boundary options
%        'Symmetric' 
%        'Replicate'
%        'Circular'
%         Scalar #  - Default to zero.
%       A choice between these strings for output options
%        'Full'
%        'Same'  - default
%       A choice between these strings for functionality options
%        'Conv' 
%        'Corr'  - default       
%
% B:   N-D array the same class as A.  If the 'Same' output option was
%      specified, B is the same size as A.  If the 'Full' output option was
%      specified the size of B is size(A)+size(H)-1, remembering that if
%      size(A)~=size(B) then the missing dimensions have a size of 1.
%
% 
% IMFILTER should use a significantly less amount of memory than CONVN. 

% MATLAB Compiler pragma: iptgetpref is indirectly invoked by the code that
% loads the Intel IPP library.
%#function iptgetpref

[a,h,boundary,flags] = parse_inputs(varargin{:});
  
rank_a = ndims(a);
rank_h = ndims(h);

% Pad dimensions with ones if filter and image rank are different
size_h = [size(h) ones(1,rank_a-rank_h)];
size_a = [size(a) ones(1,rank_h-rank_a)];

if bitand(flags,8)
  %Full output
  im_size = size_a+size_h-1;
  pad = size_h - 1;
else
  %Same output
  im_size = size_a;

  %Calculate the number of pad pixels
  filter_center = floor((size_h + 1)/2);
  pad = size_h - filter_center;
end

%Empty Inputs
% 'Same' output then size(b) = size(a)
% 'Full' output then size(b) = size(h)+size(a)-1 
if isempty(a)
  if bitand(flags,4) %Same
    b = a;
  else %Full
    if all(im_size>0)
      b = a;
      b = b(:);
      b(prod(im_size)) = 0;
      b = reshape(b,im_size);
    elseif all(im_size>=0)
      b = feval(class(a),zeros(im_size));
    else
      eid = sprintf('Images:%s:negativeDimensionBadSizeB',mfilename);
      msg = ['Error in size of B.  At least one dimension is negative. ',...
             '\n''Full'' output size calculation is: size(B) = size(A) ',...
             '+ size(H) - 1.'];
      error(eid,msg);
    end
  end
  return;
end

if  isempty(h)
  if bitand(flags,4) %Same
    b = a;
    b(:) = 0;
  else %Full
    if all(im_size>0)
      b = a;
      if all(im_size<size_a)  %Output is smaller than input
        b(:) = [];
      else %Grow the array, is this a no-op?
        b(:) = 0;
        b = b(:);
      end
      b(prod(im_size)) = 0;
      b = reshape(b,im_size);
    elseif all(im_size>=0)
      b = feval(class(a),zeros(im_size));
    else
      eid = sprintf('Images:%s:negativeDimensionBadSizeB',mfilename);
      msg = ['Error in size of B.  At least one dimension is negative. ',...
             '\n''Full'' output size calculation is: size(B) = size(A) +',...
             ' size(H) - 1.'];
      error(eid,msg);
    end
  end
  return;
end

im_size = im_size;

%Starting point in padded image, zero based.
start = pad;

% check for filter separability only if the kernel has at least
% 289 elements [17x17] (non-double input) or 49 [7x7] (double input),
% both the image and the filter kernel are two-dimensional and the
% kernel is not a row or column vector, nor does it contain any NaNs of Infs
separable = false;
numel_h = numel(h);
if isa(a,'double')
    sep_threshold = (numel_h >= 49);
else
    sep_threshold = (numel_h >= 289);
end

if sep_threshold && (rank_a == 2) && (rank_h == 2) && ...
      all(size(h) ~= 1) && ~any(isnan(h(:))) && ~any(isinf(h(:)))
  [u,s,v] = svd(h);
  s = diag(s);
  tol = length(h) * max(s) * eps;
  rank = sum(s > tol);
  if (rank == 1)
    separable = true;
  end
end

% Separate real and imaginary parts of the filter (h) in MATLAB and
% filter imaginary and real parts of the image (a) in the mex code. 
if separable
  % extract the components of the separable filter
  hcol = u(:,1) * sqrt(s(1));
  hrow = v(:,1)' * sqrt(s(1));
  
  % Create connectivity matrix.  Only use nonzero values of the filter.
  conn_logical_row = hrow~=0;
  conn_row = double(conn_logical_row); %input to the mex file must be double
  nonzero_h_row = hrow(conn_logical_row);

  conn_logical_col = hcol~=0;
  conn_col = double(conn_logical_col); %input to the mex file must be double
  nonzero_h_col = hcol(conn_logical_col);

  % intermediate results should be stored in doubles in order to
  % maintain sufficient precision
  class_of_a = class(a);
  change_class = false;
  if ~strcmp(class_of_a,'double')
    change_class = true;
    a = double(a);
  end

  % In order for IPP and non-IPP code paths to get equivalent results, we
  % need to zero pad based on the geometry of the separate row/column
  % kernels, not the full kernel.
  h_row_pad = [0 pad(2)];
  start = h_row_pad;
  a = padarray(a,h_row_pad,boundary,'both');
  out_size_row_applied = [size(a,1) im_size(2)];                        

  % apply the first component of the separable filter (hrow)
  checkMexFileInputs(a,out_size_row_applied,real(hrow),real(nonzero_h_row),conn_row,...
                     start,separable,flags);
  b_row_applied = imfilter_mex(a,out_size_row_applied,real(hrow),real(nonzero_h_row),...
                               conn_row,start,flags);
  
                           
  if ~isreal(hrow)
    b_row_applied_cmplx = imfilter_mex(a,out_size_row_applied,imag(hrow),...
                                       imag(nonzero_h_row),conn_row,...
                                       start,flags);    
    if isreal(a)
      % b_row_applied and b_row_applied_cmplx will always be real;
      % result will always be complex
      b_row_applied = complex(b_row_applied,b_row_applied_cmplx);
    else
      % b_row_applied and/or b_row_applied_cmplx may be complex;
      % result will always be complex
      b_row_applied = complex(imsubtract(real(b_row_applied),...
                                         imag(b_row_applied_cmplx)),...
                              imadd(imag(b_row_applied),...
                                    real(b_row_applied_cmplx)));
    end
  end
  
  % apply the other component of the separable filter (hcol)
  
  % prepare b_next which is an intermediate result after applying both
  % real and complex parts of hrow to the input image
  h_col_pad = [pad(1) 0];
  start = h_col_pad;
  b_row_applied = padarray(b_row_applied,h_col_pad,boundary,'both'); 
  
  checkMexFileInputs(b_row_applied,im_size,real(hcol),real(nonzero_h_col),...
                     conn_col,start,separable,flags);
  b1 = imfilter_mex(b_row_applied,im_size,real(hcol),real(nonzero_h_col),...
                    conn_col,start,flags);

  if ~isreal(hcol)
    b2 = imfilter_mex(b_row_applied,im_size,imag(hcol),imag(nonzero_h_col),...
                      conn_col,start,flags);
    if change_class
      b2 = feval(class_of_a,b2);
    end
  end
  
  % change the class back if necessary  
  if change_class
    b1 = feval(class_of_a,b1);
  end
  
  %If input is not complex, the output should not be complex. COMPLEX always
  %creates an imaginary part even if the imaginary part is zeros.
  if isreal(hcol)
    % b will always be real
    b = b1;
  elseif isreal(b_row_applied)
    % b1 and b2 will always be real. b will always be complex
    b = complex(b1,b2);
  else
    % b1 and/or b2 may be complex.  b will always be complex
    b = complex(imsubtract(real(b1),imag(b2)),imadd(imag(b1),real(b2)));
  end

else % non-separable filter case
  
  % Create connectivity matrix.  Only use nonzero values of the filter.
  conn_logical = h~=0;
  conn = double( conn_logical );  %input to the mex file must be double
  
  nonzero_h = h(conn_logical);
  
  % Zero-pad input based on dimensions of filter kernel.
  a = padarray(a,pad,boundary,'both');
  
  % Separate real and imaginary parts of the filter (h) in MATLAB and
  % filter imaginary and real parts of the image (a) in the mex code. 
  checkMexFileInputs(a,im_size,real(h),real(nonzero_h),...
                     conn,start,separable,flags);
  b1 = imfilter_mex(a,im_size,real(h),real(nonzero_h),...
                    conn,start,flags);
  
  if ~isreal(h)
    checkMexFileInputs(a,im_size,imag(h),imag(nonzero_h),...
                       conn,start,separable,flags);
    b2 = imfilter_mex(a,im_size,imag(h),imag(nonzero_h),...
                      conn,start,flags);
  end
  
  %If input is not complex, the output should not be complex. COMPLEX always
  %creates an imaginary part even if the imaginary part is zeros.
  if isreal(h)
    % b will always be real
    b = b1;
  elseif isreal(a)
    % b1 and b2 will always be real. b will always be complex
    b = complex(b1,b2);
  else
    % b1 and/or b2 may be complex.  b will always be complex
    b = complex(imsubtract(real(b1),imag(b2)),imadd(imag(b1),real(b2)));
  end
end

%======================================================================

function [a,h,boundary,flags ] = parse_inputs(a,h,varargin)

iptchecknargin(2,5,nargin,mfilename);

iptcheckinput(a,{'numeric' 'logical'},{'nonsparse'},mfilename,'A',1);
iptcheckinput(h,{'double'},{'nonsparse'},mfilename,'H',2);

%Assign defaults
flags = 0;
boundary = 0;  %Scalar value of zero
output = 'same';
do_fcn = 'corr';

allStrings = {'replicate', 'symmetric', 'circular', 'conv', 'corr', ...
              'full','same'};

for k = 1:length(varargin)
  if ischar(varargin{k})
    string = iptcheckstrs(varargin{k}, allStrings,...
                          mfilename, 'OPTION',k+2);
    switch string
     case {'replicate', 'symmetric', 'circular'}
      boundary = string;
     case {'full','same'}
      output = string;
     case {'conv','corr'}
      do_fcn = string;
    end
  else
    iptcheckinput(varargin{k},{'numeric'},{'nonsparse'},mfilename,'OPTION',k+2);
    boundary = varargin{k};
  end %else
end

if strcmp(output,'full')
  flags = bitor(flags,8);
elseif strcmp(output,'same');
  flags = bitor(flags,4);
end

if strcmp(do_fcn,'conv')
  flags = bitor(flags,2);
elseif strcmp(do_fcn,'corr')
  flags = bitor(flags,0);
end


%--------------------------------------------------------------
function checkMexFileInputs(varargin)
% a
a = varargin{1};
iptcheckinput(a,{'numeric' 'logical'},{'nonsparse'},mfilename,'A',1);

% im_size
im_size = varargin{2};
if ~strcmp(class(im_size),'double') || issparse(im_size)
  displayInternalError('im_size');
end

% h
h = varargin{3};
if ~isa(h,'double') || ~isreal(h) || issparse(h)
  displayInternalError('h');
end

% nonzero_h
nonzero_h = varargin{4};
if ~isa(nonzero_h,'double') || ~isreal(nonzero_h) || ...
      issparse(nonzero_h)
  displayInternalError('nonzero_h');
end

% start
start = varargin{6};
if ~strcmp(class(start),'double') || issparse(start)
  displayInternalError('start');
end

% separable
separable = varargin{7};
if ~islogical(separable) || issparse(separable)
  displayInternalError('separable');
end

% flags
flags = varargin{8};
if ~isa(flags,'double') ||  any(size(flags) ~= 1)
  displayInternalError('flags');
end

%--------------------------------------------------------------
function displayInternalError(string)

eid = sprintf('Images:%s:internalError',mfilename);
msg = sprintf('Internal error: %s is not valid.',upper(string));
error(eid,'%s',msg);

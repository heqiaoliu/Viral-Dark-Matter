function d = finddelay(x,y,varargin)
%FINDDELAY Estimates delays between signals.
%   D = FINDDELAY(X,Y), where X and Y are row or column vectors of length
%   LX and LY, respectively, returns an estimate of the delay D between X
%   and Y, where X serves as the reference vector. If Y is delayed with
%   respect to X, D is positive. If Y is advanced with respect to X, D is
%   negative. 
%
%   X and Y need not be exact delayed copies of each other, as
%   FINDDELAY(X,Y) returns an estimate of the delay via crosscorrelation.
%   However this estimated delay has a useful meaning only if there is
%   sufficient correlation between delayed versions of X and Y. Also, if
%   several delays are possible, as in the case of periodic signals, the
%   delay with the smallest absolute value is returned. In the case that
%   both a positive and a negative delay with the same absolute value are
%   possible, the positive delay is returned.
%
%   D = FINDDELAY(X,Y), where X is a matrix of size MX-by-NX (MX>1, NX>1)
%   and Y is a matrix of size MY-by-NY (MY>1, NY>1), returns a row vector D
%   of estimated delays between each column of X and the corresponding
%   column of Y. With this usage the number of columns of X must be equal
%   to the number of columns of Y, i.e. NX=NY. 
%
%   D = FINDDELAY(...,MAXLAG), uses MAXLAG as the maximum correlation
%   window size used to find the estimated delay(s) between X and Y:
%	* If MAXLAG is an integer-valued scalar, and X and Y are row or column
%	vectors or matrices, the vector D of estimated delays is found by
%	cross-correlating (the columns of) X and Y over a range of lags
%	-MAXLAG:MAXLAG. 
%   * If MAXLAG is an integer-valued row or column vector, X is a row or 
%   column vector of length LX>=1, and Y is a matrix of size MY-by-NY 
%   (MY>1, NY>1), the vector D of estimated delays is found by
%	cross-correlating X and column J of Y over a range of lags
%	-MAXLAG(J):MAXLAG(J), for J=1:NY. 
%   * If MAXLAG is an integer-valued row or column vector, X is a matrix of
%   size MX-by-NX (MX>1, NX>1), and Y is a row or column vector of length 
%   LY>=1, the vector D of estimated delays is found by cross-correlating
%   column J of X and Y over a range of lags -MAXLAG(J):MAXLAG(J), for
%   J=1:NX. 
%   * If MAXLAG is an integer-valued row or column vector, and X and Y are 
%   both matrices of sizes MX-by-NX (MX>1, NX>1) and MY-by-NY (MY>1,
%   NY=NX>1), respectively, the vector D of estimated delays is found by
%   cross-correlating column J of X and column J of Y over a range of lags
%   -MAXLAG(J):MAXLAG(J), for J=1:NY.
%
%   By default, MAXLAG is equal to MAX(LX,LY)-1 (two vector inputs),
%   MAX(MX,MY)-1 (two matrix inputs), MAX(LX,MY)-1 or MAX(MX,LY)-1 (one
%   vector input and one matrix input). If MAXLAG is input as [], it is
%   replaced by the default value. If any element of MAXLAG is negative, it
%   is replaced by its absolute value.  If any element of MAXLAG is not
%   integer-valued, or is complex, Inf, or NaN, FINDDELAY returns an error.
%
%   Example 1:  
%       % Y is delayed with respect to X by two samples
%       X = [ 1 2 3 ];
%       Y = [ 0 0 1 2 3]; 
%       D = finddelay(X,Y)
%
%   Example 2: 
%       % Y is advanced with respect to X by three samples
%       X = [ 0 0 0 1 2 3 0 0 ]';
%       Y = [ 1 2 3 0 ]'; 
%       D = finddelay(X,Y)
%
%   Example 3:   
%       X = [ 0 1 0 0 ;
%             1 2 0 0 ;
%             2 0 1 0 ;
%             1 0 2 1 ;
% 			  0 0 0 2 ];
%       Y = [ 0 0 1 0 ;
%             1 1 2 0 ;
%             2 2 0 1 ;
%             1 0 0 2 ;
% 			  0 0 0 0 ];
%       MAXLAG = [2 3 2 1];
%       D = finddelay(X,Y,MAXLAG)
%
%   See also XCORR, ALIGNSIGNALS.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:17:34 $ 

% Only 2 or 3 inputs are allowed.
error(nargchk(2,3,nargin,'struct'));

if ~isnumeric(x)
    % x must be numeric.
    error('comm:finddelay:firstInputNumeric', ...
        'The first input X must be numeric.');
elseif (ndims(x)>2) || (isempty(x))
    % x must be a vector or a matrix.
    error('comm:finddelay:firstInputVectorMatrix', ...
        'The first input X must be a vector or a matrix.');
end
% fft function in xcorr only works on double and single data types.
x = double(x);    
if isvector(x) 
    x = x(:);
end
[mx,nx] = size(x);


if ~isnumeric(y),
    % y must be numeric.
    error('comm:finddelay:secondInputNumeric', ...
        'The second input Y must be numeric.');
elseif (ndims(y)>2) || (isempty(y)),
    % y must be a vector or a matrix.
    error('comm:finddelay:secondInputVectorMatrix', ...
        'The second input Y must be a vector or a matrix.');
end
% fft function in xcorr only works on double and single data types.
y = double(y);    
if isvector(y)
    y = y(:);
end    
[my,ny] = size(y);


% Matrix inputs
if ~isvector(x) && ~isvector(y)
    if nx~=ny
        error('comm:finddelay:sameNumberColumns', ...
            ['When both inputs are matrices, they must have the same ' ...
            'number of columns.']);
    end    
end    
    
 
% By default maxlag is a scalar equal to max(MX,MY)-1.
maxlag_default = max(mx,my)-1;

% Process third (optional) argument.
if nargin==3  
    if ( ~isnumeric(varargin{1}) || ~isreal(varargin{1}) ),
        % maxlag must be numeric and real.
        error('comm:finddelay:maxlagNumericReal', ...
            'The third input MAXLAG must be numeric and real.');
    elseif ~isvector(varargin{1}) && ~isempty(varargin{1}),
        % maxlag must be a scalar or a vector.
        error('comm:finddelay:maxlagScalarVector', ...
            'The third input MAXLAG must be a scalar or a vector.'); 
    elseif ( any(isnan(varargin{1})) || any(isinf(varargin{1})) ),
        % maxlag cannot be Inf or NaN. 
        error('comm:finddelay:maxlagNanInf', ...
            'The third input MAXLAG cannot be Inf or NaN.');
    elseif ( varargin{1} ~= round(varargin{1}) ),
        % maxlag must be integer-valued.
        error('comm:finddelay:maxlagInteger', ...
            'The third input MAXLAG must be integer-valued.');
    elseif ( (isvector(x)) && (isvector(y)) && (length(varargin{1})>1) ),
        % If x and y are both vectors, maxlag should be a scalar.
        error('comm:finddelay:maxlagScalar', ...
            ['The third input MAXLAG must be a scalar, if X and Y are ' ...
            'both vectors.']);
    elseif ( (isvector(y)) && (length(varargin{1})>1) ...
            && (length(varargin{1})~=nx) ),
        % If maxlag is a row/column vector, it should be of same length as
        % the number of columns of X.
        error('comm:finddelay:maxlagLengthColumnsX', ...
            ['The third input MAXLAG should be the same length as the ' ...
            'number of columns of X, if X is a matrix and Y is a vector.']);
    elseif ( (isvector(x)) && (length(varargin{1})>1) ...
            && (length(varargin{1})~=ny) ),
        % If maxlag is a row/column vector, it should be of same length as
        % the number of columns of Y.
        error('comm:finddelay:maxlagLengthColumnsY', ...
            ['The third input MAXLAG should be the same length as the ' ...
            'number of columns of Y, if X is a vector and Y is a matrix.']);
    elseif ( (length(varargin{1})>1) && (length(varargin{1})~=nx) ...
            && (length(varargin{1})~=ny) ),
        % If maxlag is a row/column vector, it should be of same length as
        % the number of columns of X and Y.
        error('comm:finddelay:maxlagLengthColumnsXY', ...
            ['The third input MAXLAG should be the same length as the ' ...
            'number of columns of X and Y, if X and Y are matrices.']);
    else
        if isempty(varargin{1})
            maxlag = maxlag_default;
        else
            maxlag = double(abs(varargin{1}));
        end
    end
else
    % maxlag is set to default.
    maxlag = maxlag_default;
end


max_nx_ny=max(nx,ny);
% Create a vector of maximum window sizes, if only one maximum window size
% is specified.
if (isscalar(maxlag))
    maxlag = repmat(maxlag,1,max_nx_ny);
end

if nx<max_nx_ny
    x = repmat(x,1,max_nx_ny);
elseif ny<max_nx_ny
    y = repmat(y,1,max_nx_ny);
end    
    

% The largest maximum window size determines the size of the 
% cross-correlation vector/matrix c.
max_maxlag = max(maxlag);
% Preallocate normalized cross-correlation vector/matrix c.
c_normalized = zeros(2*max_maxlag+1,max_nx_ny);
index_max = zeros(1,max_nx_ny);
max_c = zeros(1,max_nx_ny);


% Compute absolute values of normalized cross-correlations between x and
% all columns of y: function XCORR does not take into account special case
% when either x or y is all zeros, so we don't use its normalization option
% 'coeff'. Values of normalized cross-correlations computed for a lag of
% zero are stored in the middle row of c at index i = max_maxlag+1 (c has
% an odd number of rows).
cxx0 = sum(abs(x).^2);
cyy0 = sum(abs(y).^2);
for i = 1:max_nx_ny
    if ( (cxx0(i)==0) || (cyy0(i)==0) )
        % If either sequence x or y is all zeros, set c to all zeros.
        c_normalized(:,i) = zeros(2*max_maxlag+1,1);
    else
        % Otherwise calculate c_normalized.
        c_normalized(max_maxlag-maxlag(i)+1:max_maxlag-maxlag(i)+2*maxlag(i)+1,i) ...
            = abs(xcorr(x(:,i),y(:,i),maxlag(i)))/sqrt(cxx0(i)*cyy0(i));
    end
end

% Find indices of lags resulting in the largest absolute values of
% normalized cross-correlations: to deal with periodic signals, seek the
% lowest (in absolute value) lag giving the largest absolute value of
% normalized cross-correlation.
% Find lowest positive or zero indices of lags (negative delays) giving the
% largest absolute values of normalized cross-correlations. 
[max_c_pos,index_max_pos] = max(c_normalized(max_maxlag+1:end,:),[],1);    
% Find lowest negative indices of lags (positive delays) giving the largest
% absolute values of normalized cross-correlations. 
[max_c_neg,index_max_neg] = max(flipud(c_normalized(1:max_maxlag,:)),[],1);

if isempty(max_c_neg)
    % Case where MAXLAG is all zeros.
    index_max = max_maxlag + index_max_pos;
else
    for i=1:max_nx_ny
        if max_c_pos(i)>max_c_neg(i)
            % The estimated lag is positive or zero.
            index_max(i) = max_maxlag + index_max_pos(i);
            max_c(i) = max_c_pos(i);
        elseif max_c_pos(i)<max_c_neg(i)
            % The estimated lag is negative.
            index_max(i) = max_maxlag + 1 - index_max_neg(i);
            max_c(i) = max_c_neg(i);
        elseif max_c_pos(i)==max_c_neg(i)
            if index_max_pos(i)<=index_max_neg(i)
                % The estimated lag is positive or zero.
                index_max(i) = max_maxlag + index_max_pos(i);
                max_c(i) = max_c_pos(i);
            else
                % The estimated lag is negative.
                index_max(i) = max_maxlag + 1 - index_max_neg(i);
                max_c(i) = max_c_neg(i);
            end 
        end   
    end
end

% Subtract delays.
d =  (max_maxlag + 1) - index_max;
% Set to zeros estimated delays for which the normalized cross-correlation
% values are below a given threshold (spurious peaks due to FFT roundoff
% errors).
for i=1:length(d)
    if max_c(i)<1e-8
        d(i) =  0;
        if isscalar(d) && maxlag(i)~=0
            warning('comm:finddelay:noSignificantCorrelationScalar', ...
           ['The returned delay was set to zero because no significant '...
           'correlation was found between inputs.']);
        elseif isvector(d) && maxlag(i)~=0
            warning('comm:finddelay:noSignificantCorrelationVector', ...
           ['Element %i of the returned delay vector was set to zero ' ...
           'because no significant correlation was found between inputs.'],i);
        end
    end    
end

% EOF


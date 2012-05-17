function varargout = alignsignals(x,y,varargin)
%ALIGNSIGNALS Aligns two signals, by delaying the "earliest" signal.
%   [Xa Ya] = ALIGNSIGNALS(X,Y), where X and Y are row or column vectors of
%   length LX and LY, respectively, aligns the two vectors by estimating
%   the delay D between the two. If Y is delayed with respect to X, D is
%   positive, and X is delayed by D samples. If Y is advanced with respect
%   to X, D is negative, and Y is delayed by -D samples. The aligned
%   signals Xa and Ya are returned.
%
%   [Xa Ya] = ALIGNSIGNALS(X,Y,MAXLAG) uses MAXLAG as the maximum window
%   size used to find the estimated delay D between X and Y. MAXLAG is an
%   integer-valued scalar. By default, MAXLAG is equal to MAX(LX,LY)-1. If
%   MAXLAG is input as [], it is replaced by the default value. If MAXLAG
%   is negative, it is replaced by its absolute value. If MAXLAG is not
%   integer-valued, or is complex, Inf, or NaN, ALIGNSIGNALS returns an
%   error.
%
%   [Xa Ya] = ALIGNSIGNALS(X,Y,MAXLAG,'truncate') keeps the lengths of Xa
%   and Ya the same as those of X and Y, respectively. If D is positive, D
%   zeros are pre-pended to X, and the last D samples of X are truncated.
%   If D is negative, -D zeros are pre-pended to Y, and the last -D samples
%   of Y are truncated. Note: If D>=LX, Xa will consist of LX zeros (all
%   samples of X are lost). Similarly, if -D>=LY, Ya will consist of LY
%   zeros (all samples of Y are lost). To avoid assigning a specific value
%   to MAXLAG when using the 'truncate' option, set MAXLAG to [].
%
%   [Xa Ya D] = ALIGNSIGNALS(...) returns the estimated delay D.
%   
%   Example 1: 
%        X = [ 1 2 3 ]; 
%        Y = [ 0 0 1 2 3 ]; 
%        maxlag = 2; 
%        [ Xa Ya D ] = alignsignals(X,Y,maxlag) 
%
%   Example 2: 
%        X = [ 1 2 3 ]; 
%        Y = [ 0 0 1 2 3 ]; 
%        [ Xa Ya D ] = alignsignals(X,Y,[],'truncate')
%       
%   See also FINDDELAY.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/08/01 12:17:25 $ 

% Only 2, 3 or 4 inputs are allowed.
error(nargchk(2,4,nargin,'struct'));

if ~isnumeric(x)
    % x must be numeric.
    error('comm:alignsignals:firstInputNumeric', ...
        'The first input X must be numeric.');
elseif ~isvector(x)
    % x must be a vector.
    error('comm:alignsignals:firstInputVector', ...
        'The first input X must be a scalar or a vector.');
end
[mx,nx] = size(x);
lx = length(x);


if ~isnumeric(y),
    % y must be numeric.
    error('comm:alignsignals:secondInputNumeric', ...
        'The second input Y must be numeric.');
elseif ~isvector(y),
    % y must be a vector.
    error('comm:alignsignals:secondInputVector', ...
        'The second input Y must be a scalar or a vector.');
end
[my,ny] = size(y);
ly = length(y);


% By default maxlag is a scalar equal to max(LX,LY)-1.
maxlag_default = max(lx,ly)-1;

% Process third (optional) argument.
if nargin==3 || nargin==4    
    if ( ~isnumeric(varargin{1}) || ~isreal(varargin{1}) ),
        % maxlag must be numeric and real.
        error('comm:alignsignals:maxlagNumericReal', ...
            'The third input MAXLAG must be numeric and real.');
    elseif ~isscalar(varargin{1}) && ~isempty(varargin{1}),
        % maxlag must be a scalar.
        error('comm:alignsignals:maxlagScalar', ...
            'The third input MAXLAG must be a scalar.');   
    elseif ( any(isnan(varargin{1})) || any(isinf(varargin{1})) ),
        % maxlag cannot be Inf or NaN.
        error('comm:alignsignals:maxlagNanInf', ...
            'The third input MAXLAG cannot be Inf or NaN.');
    elseif ( varargin{1} ~= round(varargin{1}) ),
        % maxlag must be integer-valued.
        error('comm:alignsignals:maxlagInteger', ...
            'The third input MAXLAG must be integer-valued.');
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

trunc_on=0;
if nargin==4
    if strcmp(varargin{2},'truncate')
        trunc_on=1;
    else
        error('comm:alignsignals:invalidOption', ...
            'Invalid option: must be ''truncate''.');
    end
end    


% Estimate delay between X and Y.
if nargin==2
    d = finddelay(x,y);
else
    d = finddelay(x,y,maxlag);
end


if d == 0   % X and Y are already aligned.
    varargout{1} = x;
    varargout{2} = y;    
elseif d > 0    % Y is estimated to be delayed with respect to X.
    if mx>1 % X is entered as a column vector.
        if trunc_on==0
            varargout{1} = [zeros(d,1) ; x]; 
        else
            if d>=mx
                warning('comm:alignsignals:firstInputTruncated', ...
                    ['All original data in the first input X has been truncated because ' ...
                    'the length of X is smaller than the estimated delay D: '...
                    'to avoid truncating this data do not use the ''trunc'' option.']);
                varargout{1} = zeros(mx,1);
            else
                varargout{1} = [zeros(d,1) ; x(1:end-d)];
            end                
        end
    else    % X is entered as a row vector.
        if trunc_on==0
            varargout{1} = [zeros(1,d) x];
        else
            if d>=nx
                warning('comm:alignsignals:firstInputTruncated', ...
                    ['All original data in the first input X has been truncated because '...
                    'the length of X is smaller than the estimated delay D: '...
                    'to avoid truncating this data do not use the ''trunc'' option.']);
                varargout{1} = zeros(1,nx);
            else
                varargout{1} = [zeros(1,d) x(1:end-d)];
            end                
        end    
    end            
    varargout{2} = y;
else    % X is estimated to be delayed with respect to Y.
    varargout{1} = x;
    if my>1 % Y is entered as a column vector.
        if trunc_on==0
            varargout{2} = [zeros(-d,1) ; y];
        else
            if (-d)>=my
                warning('comm:alignsignals:secondInputTruncated',...
                    ['All original data in the second input Y has been truncated because '...
                    'the length of Y is smaller than the estimated delay D: '...
                    'to avoid truncating this data do not use the ''trunc'' option.']);
                varargout{2} = zeros(my,1);
            else
                varargout{2} = [zeros(-d,1) ; y(1:end-(-d))];
            end                
        end
    else    % Y is entered as a row vector.
        if trunc_on==0
            varargout{2} = [zeros(1,-d) y];
        else
            if (-d)>=ny
                warning('comm:alignsignals:secondInputTruncated',...
                    ['All original data in the second input Y has been truncated because '...
                    'the length of Y is smaller than the estimated delay D: '...
                    'to avoid truncating this data do not use the ''trunc'' option.']);
                varargout{2} = zeros(1,ny);
            else
                varargout{2} = [zeros(1,-d) y(1:end-(-d))];
            end   
        end    
    end    
end    
    
varargout{3} = d;

% EOF


function varargout = strread(varargin)
%STRREAD Read formatted data from string.
%    A = STRREAD('STRING')
%    A = STRREAD('STRING','',N)
%    A = STRREAD('STRING','',param,value, ...)
%    A = STRREAD('STRING','',N,param,value, ...) reads numeric data from
%    the STRING into a single variable.  If the string contains any text data,
%    an error is produced.
%
%    [A,B,C, ...] = STRREAD('STRING','FORMAT')
%    [A,B,C, ...] = STRREAD('STRING','FORMAT',N)
%    [A,B,C, ...] = STRREAD('STRING','FORMAT',param,value, ...)
%    [A,B,C, ...] = STRREAD('STRING','FORMAT',N,param,value, ...) reads
%    data from the STRING into the variables A,B,C,etc.  The type of each
%    return argument is given by the FORMAT string.  The number of return
%    arguments must match the number of conversion specifiers in the FORMAT
%    string.  If there are more specifiers in FORMAT than fields in STRING,
%    STRREAD returns an empty value for each extra specifier.
%
%    If N is specified, the format string is reused N times.  If N is -1 (or
%    not specified) STRREAD reads the entire string.
%
%    Example
%
%      s = sprintf('a,1,2\nb,3,4\n');
%      [a,b,c] = strread(s,'%s%d%d','delimiter',',')
%
%   See TEXTREAD for more examples and definition of terms.
%   The TEXTSCAN function is intended as a replacement for both STRREAD and
%   TEXTREAD.
%
%   See also TEXTSCAN, TEXTREAD, SSCANF, FILEFORMATS, STRTOK.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2006/06/20 20:12:52 $

%   Implemented as a mex file.

% do some preliminary error checking
if nargin < 1
    error(nargchk(1,inf,nargin, 'struct'));
end

if nargout == 0
    nlhs = 1;
else
    nlhs = nargout;
end
num = numel(varargin{1});
if  num < 4095 % 4095 is dataread's buffer limit
    [varargout{1:nlhs}]=dataread('string',varargin{:});
else % Unicode chars are two bytes
    if nargin < 2
         %If format was not passed in, make sure to pass empty one.
        [varargout{1:nlhs}]=dataread('string',varargin{:}, '', 'bufsize',2*num );       
    else
        [varargout{1:nlhs}]=dataread('string',varargin{:},'bufsize',2*num );
    end
end

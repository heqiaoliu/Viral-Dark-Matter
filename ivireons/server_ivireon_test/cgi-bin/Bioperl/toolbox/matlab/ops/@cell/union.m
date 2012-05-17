function [c,ia,ib] = union(a,b,~)
%UNION  Set union for cell array of strings.
%   UNION(A,B) when A and B are vectors returns the combined values
%   from A and B but with no repetitions.  The result will be sorted.
%
%   [C,IA,IB] = UNION(A,B) also returns index vectors IA and IB such
%   that C is a sorted combination of the elements A(IA) and B(IB).
%
%   See also UNIQUE, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.10.4.10 $  $Date: 2010/02/25 08:10:12 $

nIn = nargin;

if nIn < 2
  error('MATLAB:union:TooFewInputs', 'Not enough input arguments.');
elseif nIn == 3
    warning('MATLAB:union:RowsFlagIgnored',...
       'Third argument is ignored for cell arrays.'); 
elseif nIn > 3
    error('MATLAB:union:TooManyInputs','Too many input arguments.');
end

if ischar(a)
    if isrow(a)
        a = {a};  %refrain from using cellstr to preserve trailing spaces
    else
        a = cellstr(a);
    end
end
if ischar(b)
    if isrow(b)
        b = {b};  %refrain from using cellstr to preserve trailing spaces
    else
        b = cellstr(b);
    end
end

ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
            ((size(b,1)==0 && size(b,2)==0) || length(b)==1);

isrowab = ~((size(a,1)>1 && size(b,2)<=1) || (size(b,1)>1 && size(a,2)<=1));
a = a(:); b = b(:);

% Only return required arguments from UNIQUE.
if nargout > 1
    [c,ndx] = unique([a;b]);    
else
    c = unique([a;b]);
    ndx = [];
end
if (isempty(c) && ambiguous)
  c = reshape(c,0,0);
  ia = [];
  ib = [];
elseif isrowab
  c = c'; ndx = ndx';
end

if nargout > 1 % Create index vectors.
  n = length(a);
  d = ndx > n;
  ia = ndx(~d);
  ib = ndx(d)-n;
end

function [c,ia,ib] = intersect(a,b,~)
%INTERSECT Set intersection for cell array of strings.
%   INTERSECT(A,B) when A and B are cell arrays of strings returns the 
%   strings common to both A and B. The result will be sorted.
%
%   [C,IA,IB] = INTERSECT(A,B) also returns index vectors IA and IB
%   such that C = A(IA) and C = B(IB).
%
%   See also UNIQUE, UNION, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 1984-2010 The MathWorks, Inc. 
%   $Revision: 1.13.4.8 $  $Date: 2010/02/25 08:10:09 $
%-------------------------------------------------------------------------------
% handle inputs

nIn = nargin;
nOut = nargout;

if nIn < 2
    error('MATLAB:CELL:INTERSECT:NotEnoughInputs',...
       'Not enough input arguments.'); 
elseif nIn > 2
    warning('MATLAB:CELL:INTERSECT:RowsFlagIgnored',...
       '''rows'' flag is ignored for cell arrays.'); 
end

if ~any([iscellstr(a),iscellstr(b),ischar(a),ischar(b)])
   error('MATLAB:CELL:INTERSECT','Input must be cell arrays of strings or strings')
end

ia = [];
ib = [];

if isempty(a) || isempty(b)
    c = {};
    return
end

ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
    ((size(b,1)==0 && size(b,2)==0) || length(b)==1);

% check and set flag if input is a row vector.
if ~iscell(a)
    if isrow(a)
        a = {a};  %refrain from using cellstr to preserve trailing spaces
    else
        a = cellstr(a);
    end
end

if ~iscell(b)
    if isrow(b)
        b = {b};  %refrain from using cellstr to preserve trailing spaces
    else
        b = cellstr(b);
    end
end

%Is input a non-column vector?
isrowa = ismatrix(a) && size(a,1)==1 && size(a,2) ~= 1;
isrowb = ismatrix(b) && size(b,1)==1 && size(b,2) ~= 1;

a = a(:);
b = b(:);

if nOut <= 1
    a = unique(a);
    b = unique(b);
else
    [a,ia] = unique(a);
    [b,ib] = unique(b);
end

if ispc && (length(b) == length(a)) && ~isempty(a) && isequal(a{1},b{1})
	%Sort of two sorted copies of exactly the same array takes a long
	%time on Windows.  This is to work around that issue until we
	%have a quick merge function or rewrite sort for cell arrays.
	r  = [1:3:length(a), 2:3:length(a), 3:3:length(a)];
	a = a(r); 
	b = b(r); 
	if (nOut > 1)
		ia = ia(r);
		ib = ib(r);
	end			
end

if nOut <= 1
	c = sort([a;b]);
else
	[c,ndx] = sort([a;b]);
end

d = strcmp(c(1:end-1),c(2:end));

c = c(d);
if nOut > 1
    ia = ia(ndx(d));
    ib = ib(ndx([false; d])-length(a));
end

if isrowa || isrowb
    c = c';
    ia = ia';
    ib = ib';
end

if (ambiguous && isempty(c))
    c = reshape(c,0,0);
    ia = [];
    ib = [];
end


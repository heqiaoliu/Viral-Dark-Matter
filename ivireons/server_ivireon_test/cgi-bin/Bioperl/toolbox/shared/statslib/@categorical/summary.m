function [cnts,labs] = summary(a,dim)
%SUMMARY Summary of a categorical array.
%   SUMMARY(A) displays the number of elements in the categorical array A
%   equal to each of A's possible levels.  If A contains any undefined
%   elements, the output also includes the number of undefined elements.
%
%   C = SUMMARY(A) returns counts of the number of elements in the categorical
%   array A equal to each of A's possible levels.  If A is a matrix or N-D
%   array, C is a matrix or array with rows corresponding to the A's levels.
%   If A contains any undefined elements, C contains one more row than the
%   number of A's levels, with the number of undefined elements in C(END) (or
%   C(END,:)).
%
%   [C,L] = SUMMARY(A) also returns the list of categorical level labels
%   corresponding to the counts in C.
%
%   [...] = SUMMARY(A,DIM) computes the summary along the dimension DIM of A.
%
%   See also CATEGORICAL/ISLEVEL, CATEGORICAL/ISMEMBER, CATEGORICAL/LEVELCOUNTS.

%   Copyright 2006-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2008/02/02 13:13:12 $

if nargin==1
    dim = min(find(size(a)~=1));
    if isempty(dim), dim = 1; end
end
c = levelcounts(a,dim);
if nargout ~= 1 % two outputs, or no outputs (== display)
    labs = getlabels(a); labs = labs(:);
    labs = permute(labs,circshift(1:max(dim,2),[0 dim-1]));
end
nundefs = sum(isundefined(a),dim);
if any(nundefs(:) > 0)
    c = cat(dim,c,nundefs);
    if nargout ~= 1
        labs = cat(dim,labs,categorical.undefLabel);
    end
end

if nargout < 1
    % Add row or column headers for summaries along rows or columns.
    if dim < 3
        if ndims(c) > 2
            tile = size(c); tile(1:2) = 1;
            labs = repmat(labs,tile);
        end
        c = cat(3-dim,labs,num2cell(c));
    end
    if isvector(a) && size(a,2)==1 && dim==1
        c = c'; % display summaries down a col vector as a row to save space
    end
    
    str = evalc('disp(c)');
    
    % Do some regexp magic to put the labels into summaries along higher dims.
    if 3 <= dim
        for i = 1:length(labs)
            pattern = ['(\(\:\,\:' repmat('\,[0-9]',[1,dim-3]) '\,)' ...
                       '(' num2str(i) ')' ...
                       '(' repmat('\,[0-9]',[1,ndims(c)-dim]) '\) *= *\n)'];
            rep = ['$1' labs{i} '$3'];
            str = regexprep(str,pattern,rep);
        end
    end
    
    str = str(1:end-1); % remove trailing newline
    % Find brackets containing numbers in any format, and preceded by
    % whitespace -- those are the counts.  Replace those enclosing brackets
    % with spaces.  Then replace all quotes with spaces.
    str = regexprep(str,'(\s)\[([^\]]+)\]','$1 $2 ');
    str = regexprep(str,'''',' ');
    disp(str);
else
    cnts = c;
end

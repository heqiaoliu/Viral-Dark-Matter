function [c,ia,ib] = intersect(a,b,flag)
%INTERSECT Set intersection.
%   INTERSECT(A,B) for vectors A and B, returns the values common to the
%   two vectors. MATLAB sorts the results.  A and B can be cell arrays of
%   strings.
%
%   INTERSECT(A,B,'rows') for matrices A and B that have the same number of
%   columns, returns the rows common to the two matrices. MATLAB ignores
%   the 'rows' flag for all cell arrays.
%
%   [C,IA,IB] = INTERSECT(A,B) also returns index vectors IA and IB
%   such that C = A(IA) and C = B(IB).
%
%   [C,IA,IB] = INTERSECT(A,B,'rows') also returns index vectors IA and IB
%   such that C = A(IA,:) and C = B(IB,:).
%
%   Class support for inputs A,B:
%      float: double, single
%
%   See also UNIQUE, UNION, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.21.4.11 $  $Date: 2009/09/28 20:28:06 $

%   Cell array implementation in @cell/intersect.m

nIn = nargin;

if nIn < 2
    error('MATLAB:INTERSECT:NotEnoughInputs', 'Not enough input arguments.');
end

if nIn == 2
    flag = [];
end

isrows = strcmpi(flag,'rows');

rowsA = size(a,1);
colsA = size(a,2);
rowsB = size(b,1);
colsB = size(b,2);

rowvec = ~((rowsA > 1 && colsB <= 1) || (rowsB > 1 && colsA <= 1) || isrows);

numelA = numel(a);
numelB = numel(b);
nOut = nargout;

if ~(isa(a,'opaque') || isa(b,'opaque')) 
    
    if isempty(flag)
        
        if length(a)~=numelA || length(b)~=numelB
            error('MATLAB:INTERSECT:AandBvectorsOrRowflag',...
                'A and B must be vectors, or ''rows'' must be specified.');
        end
        
        c = reshape([a([]);b([])],0,1);    % Predefined to determine class of output
        ia = zeros(0,1);
        ib = ia;
        
        % Handle empty: no elements.
        
        if (numelA == 0 || numelB == 0)
            
            % Do Nothing
            
        elseif (numelA == 1)
            
            % Scalar A: pass to ISMEMBER to determine if A exists in B.
            [tf,pos] = ismember(a,b);
            if tf
                c = a;
                ib = pos;
                ia = 1;
            end
            
        elseif (numelB == 1)
            
            % Scalar B: pass to ISMEMBER to determine if B exists in A.
            [tf,pos] = ismember(b,a);
            if tf
                c = b;
                ia = pos;
                ib = 1;
            end
            
        else % General handling.
            
            % Convert to columns.
            a = a(:);
            b = b(:);
            
            % Switch to sort shorter list.
            
            if numelA < numelB
                if nOut > 1
                    [a,ia] = sort(a);           % Return indices only if needed.
                else
                    a = sort(a);
                end
                
                [tf,pos] = ismember(b,a);     % TF lists matches at positions POS.
                
                where = zeros(size(a));       % WHERE holds matching indices
                where(pos(tf)) = find(pos);   % from set B, 0 if unmatched.
                tfs = where > 0;              % TFS is logical of WHERE.
                
                % Create intersection list.
                ctemp = a(tfs);
                
                if nOut > 1
                    % Create index vectors if requested.
                    ia = ia(tfs);
                    if nOut > 2
                        ib = where(tfs);
                    end
                end
            else
                if nOut > 1
                    [b,ib] = sort(b);           % Return indices only if needed.
                else
                    b = sort(b);
                end
                
                [tf,pos] = ismember(a,b);     % TF lists matches at positions POS.
                
                where = zeros(size(b));       % WHERE holds matching indices
                where(pos(tf)) = find(pos);   % from set B, 0 if unmatched.
                tfs = where > 0;              % TFS is logical of WHERE.
                
                % Create intersection list.
                ctemp = b(tfs);
                
                if nOut > 1
                    % Create index vectors if requested.
                    ia = where(tfs);
                    if nOut > 2
                        ib = ib(tfs);
                    end
                end
            end
            
            if isobject(c)
                c = eval([class(c) '(ctemp)']);
            else
                c = cast(ctemp,class(c));
            end
        end
        
        % If row vector, return as row vector.
        if rowvec
            c = c.';
            if nOut > 1
                ia = ia.';
                if nOut > 2
                    ib = ib.';
                end
            end
        end
        
    else    % 'rows' case
        if ~isrows
            error('MATLAB:INTERSECT:UnknownFlag', 'Unknown flag.');
        end
        
        % Automatically pad strings with spaces
        if ischar(a) && ischar(b)
            if colsA > colsB
                b = [b repmat(' ',rowsB,colsA-colsB)];
            elseif colsA < colsB
                a = [a repmat(' ',rowsA,colsB-colsA)];
            end
        elseif colsA ~= colsB && ~isempty(a) && ~isempty(b)
            error('MATLAB:INTERSECT:AandBColnumAgree',...
                'A and B must have the same number of columns.');
        end
        
        % Remove duplicates from A and B.  Only return indices if needed.
        if nOut > 1
            [a,ia] = unique(a,flag);
            [b,ib] = unique(b,flag);
            [c,ndx] = sortrows([a;b]);
        else
            a = unique(a,flag);
            b = unique(b,flag);
            c = sortrows([a;b]);
        end
        
        % Find matching entries in sorted rows.
        [rowsC,colsC] = size(c);
        if rowsC > 1 && colsC ~= 0
            % d indicates the location of matching entries
            d = c(1:rowsC-1,:) == c(2:rowsC,:);
        else
            d = zeros(rowsC-1,0);
        end
        
        d = find(all(d,2));
        
        c = c(d,:);         % Intersect is list of matching entries
        
        if nOut > 1
            n = size(a,1);
            ia = ia(ndx(d));      % IA: indices of first matches
            ib = ib(ndx(d+1)-n);  % IB: indices of second matches
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            rowsC = size(c,1);
            c = deblank(c);
            c = reshape(c,rowsC,size(c,2));
        end
    end
    
else
    % Handle objects that cannot be converted to doubles     
    if isempty(flag)
        
        if length(a)~=numelA || length(b)~=numelB
            error('MATLAB:intersect:AorBinvalidSize',...
                'A and B must be vectors or ''rows'' must be specified.');
        end
        
        c = [a([]);b([])];    % Predefined to determine class of output
        
        % Handle empty: no elements.
        
        if (numelA == 0 || numelB == 0)
            % Predefine index outputs to be of the correct type.
            ia = [];
            ib = [];
            % Ambiguous if no way to determine whether to return a row or column.
            ambiguous = ((size(a,1)==0 && size(a,2)==0) || length(a)==1) && ...
                ((size(b,1)==0 && size(b,2)==0) || length(b)==1);
            if ~ambiguous
                c = reshape(c,0,1);
                ia = reshape(ia,0,1);
                ib = reshape(ia,0,1);
            end
            
            % General handling.
            
        else
            
            % Make sure a and b contain unique elements.
            [a,ia] = unique(a(:));
            [b,ib] = unique(b(:));
            
            % Find matching entries
            [c,ndx] = sort([a;b]);
            d = find(c(1:end-1)==c(2:end));
            ndx = ndx([d;d+1]);
            c = c(d);
            n = length(a);
            
            if nOut > 1
                d = ndx > n;
                ia = ia(ndx(~d));
                ib = ib(ndx(d)-n);
            end
        end
        
        % If row vector, return as row vector.
        if rowvec
            c = c.';
            if nOut > 1
                ia = ia.';
                if nOut > 2
                    ib = ib.';
                end
            end
        end
        
    else    % 'rows' case
        if ~isrows
            error('MATLAB:intersect:UnknownFlag', 'Unknown flag.');
        end
        
        % Automatically pad strings with spaces
        if ischar(a) && ischar(b)
            if colsA > colsB
                b = [b repmat(' ',rowsB,colsA-colsB)];
            elseif colsA < colsB
                a = [a repmat(' ',rowsA,colsB-colsA)];
            end
        elseif colsA ~= colsB && ~isempty(a) && ~isempty(b)
            error('MATLAB:intersect:AandBcolnumMismatch',...
                'A and B must have the same number of columns.');
        end
        
        ia = [];
        ib = [];
        
        % Remove duplicates from A and B.  Only return indices if needed.
        if nOut <= 1
            a = unique(a,flag);
            b = unique(b,flag);
            c = sortrows([a;b]);
        else
            [a,ia] = unique(a,flag);
            [b,ib] = unique(b,flag);
            [c,ndx] = sortrows([a;b]);
        end
        
        % Find matching entries in sorted rows.
        [rowsC,colsC] = size(c);
        if rowsC > 1 && colsC ~= 0
            % d indicates the location of matching entries
            d = c(1:rowsC-1,:) == c(2:rowsC,:);
        else
            d = zeros(rowsC-1,0);
        end
        
        d = find(all(d,2));
        
        c = c(d,:);         % Intersect is list of matching entries
        
        if nOut > 1
            n = size(a,1);
            ia = ia(ndx(d));      % IA: indices of first matches
            ib = ib(ndx(d+1)-n);  % IB: indices of second matches
        end
        
        % Automatically deblank strings
        if ischar(a) && ischar(b)
            rowsC = size(c,1);
            c = deblank(c);
            c = reshape(c,rowsC,size(c,2));
        end
    end
end

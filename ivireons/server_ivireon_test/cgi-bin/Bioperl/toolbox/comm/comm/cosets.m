function cs = cosets(m,varargin)
% COSETS Produce cyclotomic cosets for a Galois field.
%   CST = COSETS(M) produces cyclotomic cosets mod (2^M - 1). Each element of the
%   cell array CST contains one cyclotomic coset.
%
%   CST = COSETS(M,PRIMPOLY) specifies the primitive polynomial of the
%   cosets.
%
%   See also MINPOL.

%    Copyright 1996-2005 The MathWorks, Inc.
%    $Revision: 1.4.4.4 $  $Date: 2005/06/27 22:16:33 $ 

% Error checking 
if(nargin>3)
    error('comm:cosets:TooManyInputs','Too many input arguments.');
end

if ( isempty(m) || prod(size(m))~=1 || ~isreal(m) || floor(m)~=m || m<1 || m>16 )
    error('comm:cosets:InvalidM','M must be a real positive integer between 1 and 16.');
end

if (nargin == 1 || isempty(varargin{1}))
    if (nargin == 3 && strcmp(varargin{2}, 'nodisplay'))
        prim_poly = primpoly(m, 'nodisplay');
    else
        prim_poly = primpoly(m);
    end
   
elseif (~isscalar(varargin{1}) || ~isnumeric(varargin{1})|| ~isprimitive(double(varargin{1})))
    error('comm:cosets:InvalidPRIMPOLY','PRIMPOLY must be a scalar integer that represents a primtive polynomial.');
else
    prim_poly = varargin{1};
end
    
n = 2^m - 1;
cs = {gf(1,m,prim_poly)};            % used for the output

ind = ones(1, n - 1);      % used to register unprocessed numbers.

if (m ~= 1)

    % convert to polynomial form
    alph=gf(2,m,prim_poly);
    powTab = alph.^(0:n-1);
    
    i = 1;
    while ~isempty(i)
        
        % to process numbers that have not been done before.
        ind(i) = 0;             % mark the register
        
        v = i;
        pk = rem(2*i, n);       % the next candidate
        
        % build cyclotomic coset containing i
        while (pk > i)
            ind(pk) = 0;    % mark the register
            v = [v pk];     % add the element
            pk = rem(pk * 2, n);    % the next candidate
        end;
        
        v_poly = powTab(v+1)';
        
        % append the coset to cs
        cs{length(cs)+1} = v_poly;
        
        % the next number.
        while ind(i)==0
            if i<numel(ind)
                i = i + 1;
            else
                i = [];
                break;
            end
        end
        
    end;   
end;
% make cs a column vector
cs = cs';

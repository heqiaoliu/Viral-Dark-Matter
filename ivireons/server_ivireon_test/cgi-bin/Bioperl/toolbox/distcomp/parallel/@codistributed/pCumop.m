function P = pCumop(fcn, A, dim)
%pCumOp Template for CUMPROD and CUMSUM for codistributed array


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 16:51:16 $

if nargin == 3
    dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
    if ~isa(A, 'codistributed')
        try
            P = fcn(A, dim);
            return;
        catch E
            throwAsCaller(E);
        end
    end
else
    dim = distributedutil.Sizes.firstNonSingletonDimension(size(A));
end

try
    % This implementation only supports codistributor1d.
    codistributed.pVerifyUsing1d(func2str(fcn), A); %#ok<DCUNK> private static
catch E
    % Error stack should only show cumprod or cumsum, not pCumop.
    throwAsCaller(E);
end

if size(A,dim) == 1 || isempty(A)
    %cumop on a singleton dimension.
    P = A;
else

    localP = fcn(getLocalPart(A),dim);
    aDist = getCodistributor(A);
    if aDist.Dimension == dim

        %Forming index
        pageindex = cell(1,ndims(A));
        [pageindex{:}] = deal(':');
        if ~isempty(localP)
            pageindex{dim} = size(localP,dim);
        end
        scale = gcat({localP(pageindex{:})}, dim);


        if ~isempty(localP)
            if isequal(fcn, @cumprod)
                setcumscale = false;
                cumscale = 1;
                for i = 1:labindex-1
                    if ~isempty(scale{i})
                        cumscale = scale{i} .* cumscale;
                        setcumscale = true;
                    end
                end
                if setcumscale
                    localP = localP .* expandToMatch(cumscale,localP,dim,ndims(A));
                end
            else % @cumsum
                setcumscale = false;
                cumscale = 0;
                for i = 1:labindex-1
                    if ~isempty(scale{i})
                        cumscale = scale{i} + cumscale;
                        setcumscale = true;
                    end
                end
                if setcumscale
                    localP = localP + expandToMatch(cumscale,localP,dim,ndims(A));
                end
            end
        end
    end
    P = codistributed.pDoBuildFromLocalPart(localP,getCodistributor(A)); %#ok<DCUNK> private method.
end


function  expandX = expandToMatch(reducedX,X,dim,ndimsA)
s = ones(1, ndimsA);
s(dim) = size(X,dim);
expandX = repmat(reducedX,s);

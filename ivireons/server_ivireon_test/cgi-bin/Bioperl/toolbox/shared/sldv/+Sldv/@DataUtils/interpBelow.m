function yi = interpBelow(x, y, xi, dimensions)  
%   YI = interpBelow(X, Y, XI, dimensions) interpolates to find YI,  
%   the values of the underlying function Y at the points in the array XI. 

%   Copyright 2008-2009 The MathWorks, Inc.
   
    n = length(x);
    ds = dimensions;
    
    if n==1
        ds = ds(1:end-1);
    end
    
    if isscalar(ds)
        yMat = y;        
    else       
        prodDs = prod(ds);
        yMat = reshape(y,[prodDs n]);
    end

    if n<1
        error('SLDV:SldvDataInterp:NotEnoughPts', ...
                'There should be at least one data point.')
    end

    if ~isvector(x)
        error('SLDV:SldvDataInterp:Xvector','X must be a vector.');
    end
        
    % Prefer column vectors for x
    xCol = x(:);

    xiCol = xi(:);

    if isscalar(ds)
        siz_yi = [length(xi) ds];
    else
        siz_yi = [ds length(xi)];
    end

    if ~isreal(x)
        error('SLDV:SldvDataInterp:ComplexX','X should be a real vector.')
    end

    if  ~isreal(xi)
        error('SLDV:SldvDataInterp:ComplexInterpPts', ...
            'The interpolation points XI should be real.')
    end

    if (any(isnan(xCol)))
        error('SLDV:SldvDataInterp:NaNinX','NaN is not an appropriate value for X.');
    end

    if (n < 2)   
        if isscalar(ds)
            yi = reshape(yMat',[n ds]);        
        else
            yi = reshape(yMat,[ds n]);
        end           
        return;
    end

    % Start the algorithm
    % We now have column vector xCol, column vector or 2D matrix yMat and
    % column vector xiCol.

    h = diff(xCol);
    eqsp = (norm(diff(h),Inf) <= eps(norm(xCol,Inf)));
    if any(~isfinite(xCol))
        eqsp = 0; % if an INF in x, x is not equally spaced
    end
    if eqsp
        h = (xCol(n)-xCol(1))/(n-1);
    end


    if any(h < 0)
        [xCol,p] = sort(xCol);
        yMat = yMat(p,:);
        if eqsp
            h = -h;
        else
            h = diff(xCol);
        end
    end
    if any(h == 0)
        error('SLDV:SldvDataInterp:RepeatedValuesX', ...
            'The values of X should be distinct.');
    end

    numelXi = length(xiCol);

    if ~eqsp && any(diff(xiCol) < 0)
        [xiCol,p] = sort(xiCol);
    else
        p = 1:numelXi;
    end

    % Find indices of subintervals, x(k) <= u < x(k+1),
    % or u < x(1) or u >= x(m-1).
    if isempty(xiCol)
        k = xiCol;
    else
        [~,k] = histc(xiCol,xCol);
        k(xiCol<xCol(1) | ~isfinite(xiCol)) = 1;
        k(xiCol>=xCol(n)) = n;
    end

    yiMat(:,p) = yMat(:,k);
    if isscalar(ds)
        yi = reshape(yiMat',siz_yi);        
    else
        yi = reshape(yiMat,siz_yi);
    end

end
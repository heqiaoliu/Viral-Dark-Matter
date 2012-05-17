function varargout = plotpickerfunc(action,fname,inputnames,inputvals)
%PLOTPICKERFUNC  Support function for Plot Picker component.

% Copyright 2009 The MathWorks, Inc.

% Default display functions for MATLAB plots
if strcmp(action,'defaultshow')
    n = length(inputvals);
    toshow = false;
    % A single empty should always return false
    if isempty(inputvals) ||  isempty(inputvals{1})
        varargout{1} = false;
        return
    end
    switch lower(fname)
        % A single matrix or a vector and matrix of compatible size.
        % Either choice with an optional scalar bar width
        case {'bar','barh'} 
            x = inputvals{1};
            if n==1                
                toshow = (isnumeric(x) || islogical(x)) && ~isscalar(x) && ...
                    ndims(x)==2 && (isvector(x) || isreal(x));
            elseif n==2 || n==3
                toshow = localAreaArgFcn(inputvals);
                % Check for unique bins if time performance allows 
                if toshow && isvector(x) && length(x)<=1000
                    toshow = min(diff(sort(x(:))))>0;
                end
                if toshow && n==3
                    p = inputvals(3);
                    toshow = isnumeric(p) && isscalar(p);
                end
            end
        % A matrix/vector or 2 vectors/matrices of compatible size with an
        % optional linespec
        case 'plot'
            if n==1
                x = inputvals{1};
                toshow =  (isnumeric(x) || islogical(x)) && ~isscalar(x) && ndims(x)<=2;
            elseif n==2
                toshow = localPlotArgFcn(inputvals);  
            elseif n==3
                toshow = localPlotArgFcn(inputvals(1:2));
                toshow = toshow && ischar(inputvals{3});
            end 
        case 'plot as multiple series vs. first input'
            if n>=3
               x = inputvals{1};
               toshow = isnumeric(x) && ~isscalar(x);
               for k=2:length(inputvals)
                   xn = inputvals{k};
                   if ~((isnumeric(xn) || islogical(xn)) && isvector(xn) && ...
                           length(xn)==length(x))
                       toshow = false;
                       break;
                   end
               end
            end
        % A matrix/vector or 2 vectors/matrices of compatible size with an
        % optional linespec
        case {'stem','stairs'}
            if n==1
                x = inputvals{1};
                toshow =  (isnumeric(x) || islogical(x)) && ~isscalar(x) && ...
                    ndims(x)<=2 && (isvector(x) || isreal(x));
            elseif n==2
                toshow = localAreaArgFcn(inputvals);  
            elseif n==3
                toshow = localAreaArgFcn(inputvals(1:2));
                toshow = toshow && ischar(inputvals{3});
            end
        case 'plot as multiple series'
            if n>=2
               x = inputvals{1};
               toshow = isnumeric(x) && ~isscalar(x);
               for k=2:length(inputvals)
                   xn = inputvals{k};
                   if ~((isnumeric(xn) || islogical(xn)) && isvector(xn) && ...
                           length(xn)==length(x))
                       toshow = false;
                       break;
                   end
               end
            end
                       
        % A matrix/vector or 2 vectors/matrices of compatible size with an
        % optional base value
        case 'area'
            if n==1
                x = inputvals{1};
                toshow =  (isnumeric(x) || islogical(x)) && ~isscalar(x) && ...
                    ndims(x)<=2 && (isvector(x) || isreal(x));
            elseif n==2
                toshow = localAreaArgFcn(inputvals);  
            elseif n==3
                toshow = localAreaArgFcn(inputvals(1:2));
                toshow = toshow && ischar(inputvals{3});
            end    
        % A vector/matrix with optional cell array of labels or
        % explosion parameter
        case {'pie','pie3'} 
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ~isscalar(x) && ndims(x)==2 && isreal(x) && ...
                    isfloat(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isnumeric(x) && ~isscalar(x) && ndims(x)==2 && isfloat(x);
                toshow = toshow && ((iscell(y) && isequal(size(y),size(x)) && ...
                    all(cellfun('isclass',y,'char'))) || (isnumeric(y) && isequal(size(y),size(x))));
            end
        % A vector/matrix with optional scalar or monotonic vector bin parameter
        case 'hist' 
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ~isscalar(x) && ndims(x)==2 && isreal(x) && ...
                    isfloat(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isnumeric(x) && isnumeric(y) && ~isscalar(x) && ndims(x)==2 && ...
                    isfloat(x);
                toshow = toshow && (isscalar(y) || ...
                        (isvector(y) && issorted(y)));                 
            end
        % A matrix or 3 vectors/matrices of compatible size with an optional scalar/vector of
        % contour levels or linespec
        case {'contour','contourf','contour3'} 
            if n==1
                x = inputvals{1};
                toshow = localIsMatrix(x);
            elseif n==2
                x = inputvals{1};
                v = inputvals{2};
                toshow = isnumeric(v) && localIsMatrix(x);
                if isscalar(v)
                    toshow = toshow && isscalar(v) && round(v)==v;
                elseif isvector(v)
                    toshow = toshow && issorted(v);
                elseif ischar(v)
                    toshow = true;
                else
                    toshow = false;
                end              
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                if localIsMatrix(x) 
                    toshow = localIsMatrix(y) && localIsMatrix(z) && ...
                        isequal(size(x),size(z)) && isequal(size(x),size(y));
                elseif localIsVector(x)
                    toshow = localIsVector(y) && localIsMatrix(z) && ...
                        length(y)==size(z,1) && length(x)==size(z,2);
                end
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                v = inputvals{4};
                toshow = isscalar(v) && isnumeric(v) && round(v)==v; 
                if toshow
                    if localIsMatrix(x) 
                        toshow = localIsMatrix(y) && localIsMatrix(z) && ...
                            isequal(size(x),size(z)) && isequal(size(x),size(y));
                    elseif localIsVector(x)
                        toshow = localIsVector(y) && localIsMatrix(z) && ...
                            length(y)==size(z,1) && length(x)==size(z,2);
                    end
                end                
            end
        % 1 to 4 x,y,z, and color matrices of compatible size. x and y 
        % matrices may optionally replaced by compatible vectors.
        case {'surf','mesh','surfc','meshc','meshz','waterfall'}
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && localIsMatrix(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isnumeric(x) && isnumeric(y) && ndims(x)==2 && ...
                       min(size(x))>1 && isequal(size(x),size(y));
            elseif n==3 || n==4
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                toshow = isnumeric(x) && isnumeric(y) && isnumeric(z);
                if toshow
                   toshow = (ndims(x)==2 && min(size(x))>1 && isequal(size(x),size(y)) && isequal(size(x),size(z))) || ...
                     (ndims(z)==2 && isvector(x) && isvector(y) && length(x)==size(z,2) && length(y)==size(z,1));
                end
                if n==4 && toshow
                    c = inputvals{4};
                    toshow = isnumeric(c) && isequal(size(z),size(x));
                end
                
            end
        % A matrix, 2 vectors and a matrix, or 3 matrices of compatible
        % size. The number of rows and columns of matrix inputs must be >=3.
        case 'surfl'
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && localIsMatrix(x) && min(size(x))>=3;
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                toshow = isnumeric(x) && isnumeric(y) && isnumeric(z) && min(size(z))>=3;
                if toshow
                   toshow = (ndims(x)==2 && min(size(x))>1 && isequal(size(x),size(y)) && isequal(size(x),size(z))) || ...
                     (ndims(z)==2 && isvector(x) && isvector(y) && length(x)==size(z,2) && length(y)==size(z,1));
                end
            end
        % 4 vectors of the same length
        case 'plotyy' 
            if n==4
                x1 = inputvals{1};
                y1 = inputvals{2};
                x2 = inputvals{1};
                y2 = inputvals{2};
                toshow = isvector(x1) && isnumeric(x1) && ~isscalar(x1) && ...
                    isvector(x2) && isnumeric(x2) && isvector(y1) && ...
                    (isnumeric(y1) || islogical(y1)) && ~isscalar(y1) && isvector(y2) && ...
                    (isnumeric(y2) || islogical(y2)) && length(x1)==length(y1) && ...
                    length(x2)==length(y2);
            end
        % A vector/matrix or 2 vectors/matrices of the compatible size with
        % an optional linespec parameter
        case {'semilogx','semilogy','loglog'} 
            if n==1
                x = inputvals{1};
                toshow = (isnumeric(x) || islogical(x)) && ~isscalar(x) && ndims(x)==2;
            elseif n==2
                toshow = localAreaArgFcn(inputvals);
            elseif n==3
                toshow = ischar(inputvals{3}) && localAreaArgFcn(inputvals(1:2));
            end
        case 'errorbar' %Between 2 to 4 vectors of the same size
            if n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isvector(x) && isnumeric(x) && ...
                    ~isscalar(x) && isvector(y) && (isnumeric(y) || islogical(y)) && ...
                    length(x)==length(y);
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                l = inputvals{3};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x) && ...
                    isvector(y) && (isnumeric(y) || islogical(y)) && length(x)==length(y);
                toshow = toshow && isvector(l) && (isnumeric(l) || islogical(l)) && ...
                    length(x)==length(l);
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                l = inputvals{3};
                u = inputvals{4};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x) && isvector(y) && ...
                    (isnumeric(y) || islogical(y)) && length(x)==length(y);
                toshow = toshow && isvector(l) && (isnumeric(l) || islogical(l)) && ...
                    length(x)==length(l);
                toshow = toshow && isvector(u) && (isnumeric(u) || islogical(u)) && ...
                    length(x)==length(u);
            end
        case {'plot3','stem3'} %3 vectors or matrices of compatible size with an optional 4th linespec
            if n==3
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                allVectors = localIsVector(x) && localIsVector(y) && localIsVector(z) && ...
                    length(x)==length(y) && length(x)==length(z);
                allMatrices = localIsMatrix(x) && localIsMatrix(y) && localIsMatrix(z) && ...
                    isequal(size(x),size(y)) && isequal(size(x),size(z));                
                toshow = allVectors || allMatrices;
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                c = inputvals{4};
                allVectors = localIsVector(x) && localIsVector(y) && localIsVector(z) && ...
                    length(x)==length(y) && length(x)==length(z);
                allMatrices = localIsMatrix(x) && localIsMatrix(y) && localIsMatrix(z) && ...
                    isequal(size(x),size(y)) && isequal(size(x),size(z));
                toshow = (allVectors || allMatrices) && ischar(c);
            end
        case 'comet' %1 or 2 vectors of the same size with optional additional tail length
            if n==1
                x = inputvals{1};
                toshow = isvector(x) && (isnumeric(x) || islogical(x)) && ...
                    ~isscalar(x) && isreal(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x) ;
                toshow = toshow && (isvector(y) || islogical(y)) && isnumeric(y)  && length(x)==length(y);
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                p = inputvals{3};
                toshow =isvector(x) && isnumeric(x) && ~isscalar(x) ;
                toshow = toshow && isvector(y) && (isnumeric(y) || islogical(y)) && ...
                    length(x)==length(y);
                toshow = toshow && isnumeric(p) && isscalar(p);
            end
        case 'pareto' %A vector and a cell array of labels or 2 vectors of the same size
            if n==1
                x = inputvals{1};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x) && isfloat(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isvector(x) && isnumeric(x) && ~isscalar(x) && isfloat(x) && ...
                    isfloat(y);
                toshow = toshow && ((isnumeric(y) && isvector(y) && length(x)==length(y)) || ...
                    (iscell(y) && length(y)==length(x) && all(cellfun('isclass',y,'char'))));
            end
        % 1 or 2 matrices with the same number of rows either with an
        % optional linespec
        case 'plotmatrix' 
            if n==1
                x = inputvals{1};
                toshow = (isnumeric(x) || islogical(x)) && ndims(x)==2 && ...
                    min(size(x))>=2 && isreal(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = (isnumeric(x) || islogical(x)) && (ischar(y) || ...
                    (size(x,1)==size(y,1) && size(x,1)>1 && ...
                    size(x,2)>1 && size(y,2)>1 && ndims(x)==2 && ndims(y)==2)) && ...
                    isreal(x) && isreal(y);
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                l = inputvals{3};
                toshow = (isnumeric(x) || islogical(x)) && ischar(l) && ...
                    size(x,1)==size(y,1) && size(x,1)>1 && ...
                    size(x,2)>1 && size(y,2)>1 && ndims(x)==2 && ndims(y)==2 && ...
                    isreal(x) && isreal(y);
            end   
        case 'scatter' %A 2-column matrix or 2 vectors of the same size with an optional area parameter or linespec
            if n==1
                x = inputvals{1};
                toshow = (isnumeric(x) || islogical(x)) && ~isscalar(x) && size(x,1)>1 && ...
                    size(x,2)==2;
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                xnumeric = isnumeric(x) || islogical(x);
                ynumeric = isnumeric(y) || islogical(y);
                toshow = isvector(x) && xnumeric && ~isscalar(x) && ...
                    ((ynumeric && isvector(y) && length(x)==length(y)) || ischar(y));
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                s = inputvals{3};
                xnumeric = isnumeric(x) || islogical(x);
                ynumeric = isnumeric(y) || islogical(y);
                toshow = isvector(x) && xnumeric && ~isscalar(x) && ...
                    ynumeric && isvector(y) && length(x)==length(y);
                toshow = toshow && (ischar(s) || (isnumeric(s) && ...
                    (isscalar(s) || (isvector(s) && all(s>0) && length(s)==length(x)))));
            end
        %3 vectors of the same size with an optional area parameter or linespec       
        case 'scatter3' 
            if n==3
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                xnumeric = isnumeric(x) || islogical(x);
                ynumeric = isnumeric(y) || islogical(y);
                znumeric = isnumeric(z) || islogical(z);
                toshow = isvector(x) && xnumeric && ~isscalar(x) && isvector(y) && ...
                    ynumeric && ~isscalar(y) && isvector(z) && znumeric && ...
                    ~isscalar(z) && length(x)==length(y) && length(y)==length(z);
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                z = inputvals{3};
                s = inputvals{4};
                xnumeric = isnumeric(x) || islogical(x);
                ynumeric = isnumeric(y) || islogical(y);
                znumeric = isnumeric(z) || islogical(z);
                toshow = isvector(x) && xnumeric && ~isscalar(x) && isvector(y) && ...
                    ynumeric && ~isscalar(y) && isvector(z) && znumeric && ...
                    ~isscalar(z) && length(x)==length(y) && length(y)==length(z);               
                toshow = toshow && (ischar(s) || (isnumeric(s) && isscalar(s)));
            end
     
        % 1 vector or matrix with optional scalar/string marker size and linespec arguments       
        case 'spy' 
            if n==1
                s = inputvals{1};
                toshow = (isnumeric(s) || islogical(s)) && ~isscalar(s) && ndims(s)==2;
            elseif n==2
                s = inputvals{1};
                l = inputvals{2};
                toshow = (isnumeric(s) || islogical(s)) && ~isscalar(s) && ndims(s)==2;
                toshow = toshow && (ischar(l) || (isnumeric(l) && isscalar(l)));
            elseif n==3
                s = inputvals{1};
                l = inputvals{2};
                m = inputvals{3};
                toshow = (isnumeric(s) || islogical(s)) && ~isscalar(s) && ndims(s)==2;
                toshow = toshow && (ischar(l) || (isnumeric(l) && isscalar(l)));
                toshow = toshow && (ischar(m) || (isnumeric(m) && isscalar(m)));
            end
        case 'rose' %1 or 2 vectors of the same size
            if n==1
                x = inputvals{1};
                toshow = isvector(x) && (isnumeric(x) || islogical(x)) && ...
                    ~isscalar(x) && isreal(x);
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                toshow = isvector(x) && (isnumeric(x) || islogical(x)) && ~isscalar(x);
                toshow = toshow && isvector(y) && isnumeric(y) && length(x)==length(y);
            end
        case 'polar' %2 vectors or matrices of the same size with optional linepsec string
            if n==1
                rho = inputvals{1};
                toshow = ndims(rho)<=2 && isnumeric(rho)  && ~isscalar(rho);
            elseif n==2 || n==3
                theta = inputvals{1};
                rho = inputvals{2};
                toshow = ndims(theta)<=2 && isnumeric(theta) && ~isscalar(theta) && ...
                    isnumeric(rho) && isequal(size(theta),size(rho));
                if toshow && n==3
                    toshow = ischar(inputvals{3});
                end
            end 
        case 'compass' %1 or 2 vectors or matrixes of compatible size with optional linepsec string
            if n==1
                u = inputvals{1};
                toshow = (isnumeric(u) || islogical(u)) && ~isscalar(u) && ...
                    ndims(u)==2 && isfloat(u);
            elseif n==2
                u = inputvals{1};
                v = inputvals{2};
                toshow = isnumeric(u) && ~isscalar(u) && ndims(u)==2 && isfloat(u) && ...
                    isfloat(v);
                toshow = toshow && (isnumeric(v) || islogical(v)) && ...
                    ((isvector(u) && isvector(v) && length(u)==length(v)) || ...
                    isequal(size(u),size(v)));
            elseif n==3
                u = inputvals{1};
                v = inputvals{2};
                s = inputvals{3};
                toshow = isnumeric(u) && ~isscalar(u) && ndims(u)==2 && isfloat(u) && ...
                    isfloat(v);
                toshow = toshow && (isnumeric(v) || islogical(v)) && ...
                    ((isvector(u) && isvector(v) && length(u)==length(v)) || ...
                    isequal(size(u),size(v)));
                toshow = toshow && ischar(s);
            end
        case {'image','imagesc'} %1 color array or 2 vectors and an color array of compatible size
            if n==1
                x = inputvals{1};
                if (isnumeric(x) || islogical(x)) && min(size(x))>1
                    if ndims(x)==2
                        toshow = true;
                    elseif ndims(x)==3 && size(x,3)==3
                        if isfloat(x)
                            toshow = (max(x(:))<=1 && min(x(:))>=0);
                        elseif isinteger(x)
                            toshow =  isa(x,'uint8') || isa(x,'uint16');
                        end
                    else
                        toshow = false;
                    end
                end
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                C = inputvals{3};
                if isvector(x) && isnumeric(x) && isvector(y) && ...
                       isnumeric(y) && (isnumeric(C) || islogical(C))
                    if ndims(C)==2
                        toshow = true;
                    elseif ndims(C)==3 && size(C,3)==3
                        if isfloat(C)
                            toshow = (max(C(:))<=1 && min(C(:))>=0);
                        elseif isinteger(x)
                            toshow =  isa(C,'uint8') || isa(C,'uint16');
                        end
                    else
                        toshow = false;
                    end
                end
            end
        case 'pcolor' %1 color array or 2 vectors and an color array of compatible size
            if n==1
                x = inputvals{1};
                if isnumeric(x)  && min(size(x))>1
                    if ndims(x)==2
                        toshow = true;
                    elseif ndims(x)==3 && size(x,3)==3
                        toshow = max(x(:))<=1 && min(x(:))>=0;
                    else
                        toshow = false;
                    end
                end
            elseif n==3
                x = inputvals{1};
                y = inputvals{2};
                C = inputvals{3};
                if isvector(x) && isnumeric(x) && isvector(y) && ...
                       isnumeric(y) && isnumeric(C)
                    if ndims(C)==2 && size(C,1)==length(y) && size(C,2)==length(x)
                        toshow = true;
                    elseif ndims(C)==3 && size(C,3)==3
                        toshow = max(C(:))<=1 && min(C(:))>=0;
                    else
                        toshow = false;
                    end
                end
            end
        case 'ribbon' %1 matrix with 2 matrices or vectors of the same size with an optional scalar width parameter
            if n==1
                x = inputvals{1};
                toshow = isnumeric(x) && ndims(x)==2 && size(x,1)>1 && size(x,2)>1;
            elseif n==2
                x = inputvals{1};
                y = inputvals{2};
                if isnumeric(y) && isscalar(y)
                    toshow = isnumeric(x) && ndims(x)==2 && size(x,1)>1 && size(x,2)>1;
                else
                    toshow = isnumeric(x) && isnumeric(y) && ...
                        ((isvector(x) && isvector(y) && length(x)==length(y)) || ...
                        isequal(size(x),size(y)));
                end
            end
        case 'ezplot' % A function handle with an optional range of x values  
            if n==1
                fcn = inputvals{1};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==1;
            elseif n==2
                fcn = inputvals{1};
                x = inputvals{2};
                toshow = isa(fcn,'function_handle') && isnumeric(x) && isvector(x) && ...
                    nargin(fcn)==1;
            end
        case 'ezplot3' % 3 parametric function handles with an optional domain range vector
            if n==3
               fcnx = inputvals{1};
               fcny = inputvals{2};
               fcnz = inputvals{3};
               toshow = isa(fcnx,'function_handle') && isa(fcny,'function_handle') && ...
                   isa(fcnz,'function_handle') && nargin(fcnx)==1 && nargin(fcny)==1 && ...
                   nargin(fcnz)==1;
            elseif n==4
               fcnx = inputvals{1};
               fcny = inputvals{2};
               fcnz = inputvals{3};
               range = inputvals{4};
               toshow = isa(fcnx,'function_handle') && isa(fcny,'function_handle') && ...
                   isa(fcnz,'function_handle') && nargin(fcnx)==1 && nargin(fcny)==1 && ...
                   nargin(fcnz)==1; 
               toshow = toshow && isnumeric(range) && isvector(range) && ...
                   length(range)==2 && range(2)>range(1);
            end
        case 'ezpolar' % A function handle with an optional range of theta values  
            if n==1
                fcn = inputvals{1};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==1;
            elseif n==2
                fcn = inputvals{1};
                theta = inputvals{2};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==1 && ...
                    isnumeric(theta) && isvector(theta) && ...
                    length(theta)==2 && theta(2)>theta(1);
            end
        case {'ezcontour','ezcontourf'} % A 2-input function handle with an optional integer grid parameter or a 2 or 4 element domain vector
             if n==1
                fcn = inputvals{1};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==2;
             elseif n==2
                fcn = inputvals{1};
                domain = inputvals{2};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==2 && ...
                    isnumeric(domain) && (isequal(size(domain),[2 1]) ||  ...
                    isequal(size(domain),[4 1]) || (ndims(domain)==2 && ...
                    size(domain,1)==size(domain,2)));
             end
        case {'ezsurf','ezsurfc','ezmesh','ezmeshc'} % A 2-input function handle or 3 2-input function handles with an optional 2 or 4 element domain vector
             if n==1
                fcn = inputvals{1};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==2;
             elseif n==2
                fcn = inputvals{1};
                domain = inputvals{2};
                toshow = isa(fcn,'function_handle') && nargin(fcn)==2 && ...
                    isnumeric(domain) && (isequal(size(domain),[2 1]) ||  ...
                    isequal(size(domain),[4 1]));
             elseif n==3
               fcnx = inputvals{1};
               fcny = inputvals{2};
               fcnz = inputvals{3};
               toshow = isa(fcnx,'function_handle') && isa(fcny,'function_handle') && ...
                   isa(fcnz,'function_handle') && nargin(fcnx)==2 && nargin(fcny)==2 && ...
                   nargin(fcnz)==2; 
             end
        case 'slice' % 3 dimensional array with 3 vectors defining slice planes
            if n==4
                V = inputvals{1};
                sx = inputvals{2};
                sy = inputvals{3};
                sz = inputvals{4};
                toshow = isnumeric(V) && ndims(V)==3 && isnumeric(sx) && ...
                    isvector(sx) && isnumeric(sy) && isvector(sy) && ...
                    isnumeric(sz) && isvector(sz);
            end
        case 'feather' % A numeric array or 2 numeric arrays of the same size
             if n==1
                Z = inputvals{1};
                toshow = (isnumeric(Z) || islogical(Z)) && ~isscalar(Z) && isfloat(Z);
             elseif n==2;
                U = inputvals{1};
                V = inputvals{2};
                toshow = (isnumeric(U) || islogical(U)) && (isnumeric(V) || islogical(V)) && ...
                    ~isscalar(U) && isfloat(U) && isfloat(V) && isequal(size(U),size(V));
             end
        case 'quiver' % 2 or 4 numeric arrays of the same size
            if n==2;
                u = inputvals{1};
                v = inputvals{2};
                toshow = (isnumeric(u) || islogical(u)) && ~isscalar(u) && ...
                    (isnumeric(v) || islogical(v)) && isequal(size(u),size(v));
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                u = inputvals{3};
                v = inputvals{4};
                numericx = (isnumeric(x) || islogical(x));
                numericy = (isnumeric(y) || islogical(y));
                numericu = (isnumeric(u) || islogical(u));
                numericv = (isnumeric(v) || islogical(v));
                toshow = numericu && ~isscalar(u) && numericv && ...
                    numericx && numericy && isequal(size(u),size(v)) && ...
                    isequal(size(x),size(u)) && isequal(size(y),size(u));
            end
        case 'quiver3' % 4 numeric arrays of the same size
           if n==4
                z = inputvals{1};
                u = inputvals{2};
                v = inputvals{3};
                w = inputvals{4};
                numericz = (isnumeric(z) || islogical(z));
                numericu = (isnumeric(u) || islogical(u));
                numericv = (isnumeric(v) || islogical(v));
                numericw = (isnumeric(w) || islogical(w));
                toshow = numericz && ~isscalar(z) && numericu && ...
                    numericv && numericw && isequal(size(z),size(u)) && ...
                    isequal(size(z),size(v)) && isequal(size(z),size(w));
           end
        case 'streamslice' % Either 2 or 4 3-dimensional arrays of the same size
            if n==2;
                u = inputvals{1};
                v = inputvals{2};
                toshow = (isnumeric(u) || islogical(u))  && ~isscalar(u) && ...
                    (isnumeric(v) || islogical(v)) && ndims(u)==3 && ...
                    isequal(size(u),size(v));
            elseif n==4
                x = inputvals{1};
                y = inputvals{2};
                u = inputvals{3};
                v = inputvals{4};
                toshow = (isnumeric(u) || islogical(u)) && ~isscalar(u) && ...
                    (isnumeric(v) || islogical(v)) && ...
                    isnumeric(x) && isnumeric(y) && ndims(x)==3 && isequal(size(u),size(v)) && ...
                    isequal(size(x),size(u)) && isequal(size(y),size(u));
            end    
        case 'streamline' % Cell array of double arrays produced by stream2 or stream3
            if n==1 && ~isempty(inputvals{1}) && iscell(inputvals{1})
                toshow = cellfun('isclass',inputvals{1},'double');
            end    
    end
    varargout{1} = toshow;
% Default execution strings for MATLAB plots
elseif strcmp(action,'defaultdisplay') 
    n = length(inputnames);
    appendedInputs = repmat({','},1,2*n-1);
    appendedInputs(1:2:end) = inputnames;
    inputStr = cat(2,appendedInputs{:});  
    
    dispStr = '';
    switch lower(fname)
        case 'scatter'
           if n==2
              dispStr =  [lower(fname) '(' inputnames{1} ',' inputnames{2} ',''DisplayName'',''' ...
                inputnames{2} ' vs ' inputnames{1} ''',''XDataSource'',''' inputnames{1} ...
               ''',''YDataSource'',''' inputnames{2} ''');figure(gcf)'];
           elseif n==1
               if length(regexpi(inputnames{1},'\(.*\)'))==1 
                  dispStr =  [lower(fname) '(getcolumn(' inputnames{1} ',1),getcolumn(' inputnames{1} ',2),''DisplayName'',''' ...
                     inputnames{1} '(:,2) vs. ' inputnames{1} '(:,1)'',''YDataSource'',''' inputnames{1} '(:,2)'');figure(gcf)'];
               else
                  dispStr =  [lower(fname) '(' inputnames{1} '(:,1),' inputnames{1} '(:,2),''DisplayName'',''' ...
                    inputnames{1} '(:,2) vs. ' inputnames{1} '(:,1)'',''YDataSource'',''' inputnames{1} '(:,2)'');figure(gcf)'];
               end
           elseif n==3
              dispStr =  [lower(fname) '(' inputnames{1} ',' inputnames{2} ',' inputnames{3} ');figure(gcf)']; 
           end
        case 'plot'          
           if n==2
               % The DisplayName should only use the x vs. y form if y is a
               % vector.
               if isvector(inputvals{2})
                  dispStr =  [lower(fname) '(' inputnames{1} ',' inputnames{2} ',''DisplayName'',''' ...
                   inputnames{2} ' vs. ' inputnames{1} ''',''XDataSource'',''' inputnames{1} ...
                  ''',''YDataSource'',''' inputnames{2} ''');figure(gcf)'];
               else
                  dispStr =  [lower(fname) '(' inputnames{1} ',' inputnames{2} ',''DisplayName'',''' ...
                   inputnames{2} ''',''XDataSource'',''' inputnames{1} ...
                  ''',''YDataSource'',''' inputnames{2} ''');figure(gcf)'];
               end
           elseif n==1
               % Data must be real to use a YDataSource or linked plots
               % or refreshData will write the real part of the YDataSource
               % to the YData (g539861)
               if nargin>=4 && isreal(inputvals{1})
                   dispStr =  [lower(fname) '(' inputnames{1} ',''DisplayName'',''' ...
                     inputnames{1} ''',''YDataSource'',''' inputnames{1} ''');figure(gcf)'];
               else
                   dispStr =  [lower(fname) '(' inputnames{1} ');figure(gcf)'];
               end
           end
        case {'plot3','errorbar','stem3','scatter3','contour','contourf','surf'}               
              dispStr =  [lower(fname) '(' inputStr ',''DisplayName'',''' ...
                inputStr ''');figure(gcf)'];   
        case {'semilogx','semilogy','loglog','area','stem',...
                'stairs','bar','barh'}
            if n==2 && isvector(inputvals{1})
                dispStr =  [lower(fname) '(' inputStr ',''DisplayName'',''' ...
                  inputnames{2} ' vs ' inputnames{1} ''');figure(gcf)'];             
            else
                dispStr =  [lower(fname) '(' inputStr ',''DisplayName'',''' ...
                  inputStr ''');figure(gcf)']; 
            end
        case 'plot as multiple series' 
            dispStr = [dispStr sprintf('plot(%s,''DisplayName'',''%s'',''YDataSource'',''%s'');hold all;',...
                    inputnames{1},inputnames{1},inputnames{1})];
            for k=2:length(inputnames);
                dispStr = [dispStr sprintf('plot(%s,''DisplayName'',''%s'',''YDataSource'',''%s'');',...
                    inputnames{k},inputnames{k},inputnames{k})]; %#ok<AGROW>
            end;
            dispStr = [dispStr,'hold off;figure(gcf);'];
        case 'plot as multiple series vs. first input'
            if length(inputnames)>=2
                for k=2:length(inputnames)
                    dispStr = [dispStr sprintf('plot(%s,%s,''DisplayName'',''%s'',''XDataSource'',''%s'',''YDataSource'',''%s'');',...
                        inputnames{1},inputnames{k},inputnames{k},...
                        inputnames{1},inputnames{k})]; %#ok<AGROW>
                    if k==2
                        dispStr = [dispStr,'hold all;']; %#ok<AGROW>
                    end
                end;
                dispStr = [dispStr,'hold off;figure(gcf);'];    
            end
        case 'plot selected columns'
              dispStr =  ['plot(' inputnames{1} ',''DisplayName'',''' ...
                inputnames{1} ''',''YDataSource'',''' inputnames{1} ''');figure(gcf)'];
    end                    
    varargout{1} = dispStr;
elseif strcmp(action,'defaultlabel')
    n = length(inputnames);       
    lblStr = '';
    switch lower(fname)
        case 'plot'            
            if n==1 
                varname = inputnames{1};
                vardata = inputvals{1};
                if ndims(vardata)==2 
                    if length(regexpi(varname,'\(.*\)'))==1                        
                        lblStr = xlate('Plot selected columns');
                    elseif min(size(vardata))>1
                        lblStr = xlate('Plot all columns');
                    else
                        lblStr = [fname '(' varname ')'];
                    end
                else
                    lblStr = '';
                end
            else
                lblStr = '';
            end
        case 'scatter'
            if n==1 
                vardata = inputvals{1};
                varname = inputnames{1};
                if ndims(vardata)==2 && size(vardata,2)==2
                    if length(regexpi(varname,'\(.*\)'))==1  
                        lblStr = xlate('Scatter plot for selected columns');
                    else
                        lblStr = [fname '(' varname '(:,1), ' varname '(:,2)' ')'];
                    end
                else
                    lblStr = '';
                end
            else
                lblStr = '';
            end
        case 'plot as multiple series vs. first input'
            lblStr = xlate('Plot as multiple series vs. first input');
        case 'plot as multiple series' 
            lblStr = xlate('Plot as multiple series' );
    end
    varargout{1} = lblStr;
% Return all the class names for the specified object
elseif strcmp(action,'getclassnames')
    h = inputvals;
    
    % Cache the lasterror state
    errorState = lasterror; %#ok<LERR,NASGU>
    
    try
        % Try mcos first
        if isobject(h)
           varargout{1} = [class(h);superclasses(h)];
           return;
        end

        % Now try UDD
        try 
            classH = classhandle(h);
        catch %#ok<CTCH>
            varargout{1} = {};
            return;
        end

        % There is no multiple inheritance in udd, so just ascend the class
        % hierarchy
        classArray = classH;
        while ~isempty(classH.Superclasses)
            classArray = [classArray;classH.Superclasses]; %#ok<AGROW>
            classH = classH.Superclasses;
        end
        classNames = get(classArray,{'Name'}); 
        for k=1:length(classArray)
            if ~isempty(classArray(k).Package)
                classNames{k} = sprintf('%s.%s',classArray(k).Package.Name,classNames{k});
            end
        end
        varargout{1} = classNames;
    catch %#ok<CTCH>
        % Prevent drooling of the lasterror state
        lasterror(errorstate); %#ok<LERR>
        varargout{1} = {};
    end
    
    
    
end


function status = localIsVector(x)

status = (isnumeric(x) || islogical(x)) && ~isscalar(x) && isvector(x);

function status = localIsMatrix(x)

status = (isnumeric(x) || islogical(x)) && ~isscalar(x) && ndims(x)==2 && ...
    min(size(x))>1;

function toshow = localPlotArgFcn(inputvals)

x = inputvals{1};
y = inputvals{2};
toshow =  isnumeric(x) && ~isscalar(x) && ndims(x)<=2 && isreal(x);
toshow =  toshow && (isnumeric(y) || islogical(y)) && ~isscalar(y) && ...
    ndims(y)<=2 && isreal(y);
if toshow && ~isvector(x) && ~isvector(y)
    toshow = isequal(size(x),size(y));
elseif toshow && ~isvector(x)
    toshow = any(length(y)==size(x));
elseif toshow && ~isvector(y)
    toshow = any(length(x)==size(y));
elseif toshow
    toshow = length(x)==length(y);
end

function toshow = localAreaArgFcn(inputvals)

x = inputvals{1};
y = inputvals{2};
toshow =  isnumeric(x) && ~isscalar(x) && ndims(x)<=2 && isreal(x);
toshow =  toshow && (isnumeric(y) || islogical(y)) && ~isscalar(y) && ndims(y)<=2 && isreal(y);
if toshow && ~isvector(x)
    toshow = isequal(size(x),size(y));
elseif toshow && isvector(x)
    toshow = any(length(x)==size(y));
end


function [D,model,termstart,termend] = x2fx(x,model,categ,catlevels)
%X2FX   Convert predictors to design matrix.
%
%   D = X2FX(X,MODEL) converts a matrix of predictors X to a design 
%   matrix D for regression analysis.  Distinct predictor variables 
%   should appear in different columns of X.
%
%   The optional input MODEL controls the regression model.  By default, 
%   X2FX returns the design matrix for a linear additive model with a 
%   constant term.  MODEL can be any one of the following strings:
%
%     'linear'        Constant and linear terms (the default)
%     'interaction'   Constant, linear, and interaction terms
%     'quadratic'     Constant, linear, interaction, and squared terms
%     'purequadratic' Constant, linear, and squared terms
%
%   If X has n columns, the order of the columns of D for a full 
%   quadratic model is:
%
%     1.  The constant term
%     2.  The linear terms (the columns of X, in order 1,2,...,n)
%     3.  The interaction terms (pairwise products of columns of X,
%         in order (1,2), (1,3), ..., (1,n), (2,3), ..., (n-1,n)
%     4.  The squared terms (in the order 1,2,...,n)
%
%   Other models use a subset of these terms, in the same order.
%
%   Alternatively, MODEL can be a matrix specifying polynomial terms of 
%   arbitrary order.  In this case, MODEL should have one column for each 
%   column in X and one row for each term in the model.  The entries in 
%   any row of MODEL are powers for the corresponding columns of X.  For 
%   example, if X has columns X1, X2, and X3, then a row [0 1 2] in MODEL 
%   would specify the term (X1.^0).*(X2.^1).*(X3.^2).  A row of all zeros 
%   in MODEL specifies a constant term, which you can omit.
%
%   D = X2FX(X,MODEL,CATEG) treats columns with numbers listed in the
%   vector CATEG as categorical variables.  Terms involving categorical
%   variables produce dummy variable columns in D.  Dummy variables are 
%   computed under the assumption that possible categorical levels are 
%   completely enumerated by the unique values that appear in the 
%   corresponding column of X.
%
%   D = X2FX(X,MODEL,CATEG,CATLEVELS) accepts a vector CATLEVELS the same 
%   length as CATEG, specifying the number of levels in each categorical 
%   variable.  In this case, values in the corresponding column of X must 
%   be integers in the range from 1 to the specified number of levels.  Not 
%   all of the levels need to appear in X.
%
%   Example: X = [1 10     MODEL = [0 0     D = [1 1 10 10  1
%                 2 20              1 0          1 2 20 40  4
%                 3 10              0 1          1 3 10 30  9
%                 4 20              1 1          1 4 20 80 16
%                 5 15              2 0]         1 5 15 75 25
%                 6 15]                          1 6 15 90 36]
%   Let A and B represent the two columns of X.  The rows of the MODEL
%   matrix specify the terms 1, A, B, A*B, and A^2.  The output matrix
%   D has one column for each of these terms.
%
%   X2FX is a utility used by a variety of other functions, such
%   as RSTOOL, REGSTATS, CANDEXCH, CANDGEN, CORDEXCH, and ROWEXCH.
% 
%   See also RSTOOL, REGSTATS, CANDEXCH, CANDGEN, CORDEXCH, ROWEXCH. 

%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:30 $

[m,n]  = size(x);

if isa(x,'single')
   Dclass = 'single';
else
   Dclass = 'double';
end

if nargin<2 || isempty(model)
   model = 'linear';
end
if nargin<3
    categ = [];
end
if nargin<4
    catlevels = [];
end
catbool = ismember(1:n, categ);

% Convert our built-in model names to the corresponding matrix form
if ischar(model)
    model = modelname2mat(model,n,categ);
end

vardf = ones(1,n);              % degrees of freedom of each var
if isempty(catlevels)
    % Determine the possible values of each categorical variable.
    % Replace those values by integers.
    for j=1:length(categ)
        cj = categ(j);
        [uv,ignore,uidx] = unique(x(:,cj));
        vardf(cj) = length(uv)-1;
        x(:,cj) = uidx;
    end
else
   % Make sure all categorical variables take valid values
    vardf(categ) = catlevels - 1;
    for j=1:length(categ)
        cj = categ(j);
        if any(~ismember(x(:,cj),1:catlevels(j)))
           error('stats:x2fx:Categories',...
                 'Not all values of column %d of X are in 1:%d.', ...
                 cj, catlevels(j));
        end
    end
end

if ischar(model)
    % Allows for extensions to named higher order models. (e.g. 'cubic')
    D = feval(model,x);
    termstart = [];
    termend = [];
else
   [row,col] = size(model);
   if col ~= n
      error('stats:x2fx:BadSize',...
            ['A numeric second argument must have the same number ' ...
             'of columns as the first argument.']);
   end
   if any(model(:,categ)>1,1)
      error('stats:x2fx:BadModel',...
            'MODEL cannot specify powers for a categorical variable.');
   end      

   % Allocate space for the dummy variables for all terms
   termdf = prod(max(1, (model>0).*repmat(vardf,row,1)),2);
   termend = cumsum(termdf);
   termstart = termend - termdf + 1;
   D = zeros(m,termend(end),Dclass);

   allrows = (1:m)';
   for idx = 1:row
      cols = termstart(idx):termend(idx);
      pwrs = model(idx,:);
      t = pwrs>0;
      C = 1;                      % for constant or pure categorical terms
      if any(t)
         if any(pwrs(~catbool));  % make continuous part of term
             C = makecontinuousterm(x, pwrs.*~catbool);
         end
         if any(pwrs(catbool)>0)
             % Make indicators for all but last category
             Z = zeros(m,termdf(idx));
             collist = find(pwrs>0 & catbool);
             xcol = x(:,collist(1));
             keep = (xcol <= vardf(collist(1)));
             colnum = xcol;
             cumdf = 1;
             for j=2:length(collist)
                 cumdf = cumdf * vardf(collist(j-1));
                 xcol = x(:,collist(j));
                 keep = keep & (xcol <= vardf(collist(j)));
                 colnum = colnum + cumdf * (xcol-1); 
             end
             if length(C)>1
                 C = C(keep);
             end

             % Assign 1, or continuous part, into proper col of each row
             Z(sub2ind(size(Z),allrows(keep),colnum(keep))) = C;
             C = Z;
         end
      end
      D(:,cols) = C;
   end
end

% -------------------------------------
function C = makecontinuousterm(x,pwrs)
%MAKECONTINUOUSTERM Make a continuous term from variables values
%   C=MAKECONTINUOUSTERM(X,PWRS) computes C as the product of X
%   raised to the powers in PWRS.  Can be used to compute the
%   continuouse part of a term such as CONT^2*CAT by including the 2
%   for the continuous row and setting the CAT power to 0.
  
C = ones(size(x,1),1);
collist = find(pwrs>0);
for j=1:length(collist)
    cj = collist(j);
    exponent = pwrs(cj);
    if exponent==1
        C = C .* x(:,cj);
    else
        C = C .* x(:,cj) .^ exponent;
    end
end


% -------------------------------
function M=modelname2mat(model,n,categ)
%MODELNAME2MAT Generate a model matrix for a model name
%   M=MODELNAME2MAT(MODEL,N,CATEG) creates a matrix M that specifies
%   the model MODEL, for N variables, of which the ones listed in
%   the vector CATEG are categorical.

% Figure out which types of terms are required for the model with this name
len = length(model);
if strncmpi(model,'linear',len) || strncmpi(model,'additive',len)
   hasint = false;
   hasquad = false;
elseif strncmpi(model,'interactions',len)
   hasint = true;
   hasquad = false;
elseif strncmpi(model,'quadratic',len)
   hasint = true;
   hasquad = true;
elseif strncmpi(model,'purequadratic',len)
   hasint = false;
   hasquad = true;
else
   % Maybe an error, but we do support function names here
   M = model;
   return
end

% Create each part
I = eye(n);
M = [zeros(1,n); I];                % constant and linear
if hasint && n>1                    % interaction
    [r,c] = find(tril(ones(n),-1));
    nterms = length(r);
    intpart = zeros(nterms,n);
    intpart(sub2ind(size(intpart),(1:nterms)',r)) = 1;
    intpart(sub2ind(size(intpart),(1:nterms)',c)) = 1;
else
    intpart = zeros(0,n);
end
if hasquad                           % quadratic
    quadpart = 2*I;
    quadpart(categ,:) = [];
else
    quadpart = zeros(0,n);
end

M = [M; intpart; quadpart];
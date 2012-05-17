function [nlobj, sigma2, estinfo] = initwnet(nlobj, yvec, regmat, algo)
%INITWNET: initialize wavenet
%
%  [nlobj, sigma2, estinfo] = initwnet(nlobj, yvec, regmat, algo)
%
%  yvec: nobs-by-1 vector
%  regmat:  nobs-by-regdim matrix

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2009/11/09 16:24:17 $

% Author(s): Qinghua Zhang

numunits = nlobj.NumberOfUnits;

if strcmpi(algo.Display, 'full')
    smprintf displayon
else
    smprintf displayoff
end

displayon = strcmpi(algo.Display, 'on') || strcmpi(algo.Display, 'full');

[nobs, regdim] = size(regmat);

nlregs = nlobj.NonlinearRegressors;
if ischar(nlregs) && strcmpi(nlregs, 'all')
    nlregs = 1:regdim;
end
if isempty(nlregs)
    nlregs = zeros(1,0);
end

nlregs = nlregs(:).'; %ensure row shape (r.s.)

% Compose the projection matrix from nlregs
pmat = zeros(regdim, length(nlregs));
ind = sub2ind(size(pmat), nlregs, 1:length(nlregs));
pmat(ind) = 1;

regmean = mean(regmat,1);
regmat = regmat - regmean(ones(nobs,1), :);  %  regmat mean removal

% Nonlinear regressors
pct = pmat * PCAProjection(regmat*pmat);
xnl =  regmat * pct;

% Linear regressors
if strcmpi(nlobj.LinearTerm, 'on')
    lct = PCAProjection(regmat);
else
    lct = ones(regdim, 0);
end
xlin = [ones(nobs,1) regmat * lct];
% Note: xlin includes the ones for the offset (bias) term. Therefore
% xlin is not empty in the case LinearTerm='off'.

ymean = mean(yvec,1);
yvec = yvec - ymean;  % yvec has now zero mean

% Linear Model Extension, part 1/3
% Part before clearing regmat
hth = nlobj.Parameters;
if ~isempty(hth.LinearCoef) && ~isinitialized(nlobj) % The 2nd condition checks empty fields.
  extlin = hth.LinearCoef;
    lthLinearCoef = length(extlin);
  if lthLinearCoef < regdim
    % Fill initial customreg coefficients with zero.
    extlin = [extlin; zeros(regdim-lthLinearCoef, 1)];
    end
  LmdlExtFlag = true;
else
  LmdlExtFlag = false;
end

clear regmat

dimxnl = size(xnl,2);

%BEGIN build pyramidal multi-grids
options = nlobj.Options;
mincells = options.MinCells;       % min number of cells
maxcells = options.MaxCells;       % max number of cells
minpoints = options.FinestCell;    % min number of data points in each cell

if ischar(minpoints)              % if auto mode for minpoints
    minpoints = 4*dimxnl;           % auto mode depends on data dimension
    options.FinestCell = minpoints;  % set minpoints in options
end

smprintf('minpoints = %d\n', minpoints);

% Build the grid of dilations and transitions
[Dila, Tran] = multgrid(xnl, options);

% If too many cells in the built multi-grids, increase minpoints
ncells = size(Dila,1);  % number of cells in the built multi-grids
while (ncells>maxcells)
    smprintf('Too many cells found, increasing FinestCell.\n')
    minpoints = max(1, ceil(1.2*minpoints));     % decrease minpoints
    options.FinestCell = minpoints;              % set minpoints in options
    smprintf('FinestCell = %d\n', minpoints);
    [Dila, Tran] = multgrid(xnl, options);      % call multgrid with new options
    ncells = size(Dila,1);                      % number of cells
end

% If too few cells in the built multi-grids, decrease minpoints
ncells = size(Dila,1);  % number of cells in the built multi-grids
while (ncells<mincells) && (ncells<(0.25*nobs)) && (minpoints>=2)
    smprintf('Too few cells found, decreasing FinestCell.\n')
    minpoints = max(1, fix(0.8*minpoints));      % decrease minpoints
    options.FinestCell = minpoints;              % set minpoints in options
    smprintf('FinestCell = %d\n', minpoints);
    [Dila, Tran] = multgrid(xnl, options);      % call multgrid with new options
    ncells = size(Dila,1);                      % number of cells
end

if ~isempty(nlregs) && ncells<1
    ctrlMsgUtils.error('Ident:idnlfun:wavenetInitTooFewSamples')
end
if ncells>maxcells
    [Dila, Tran] = reducemultgrid(Dila, Tran, xnl, maxcells);
    ncells = size(Dila,1);
end
%END build pyramidal multi-grids

smprintf('Generating basis function candidates ...');

maxsize = algo.MaxSize;

% Check norms of basis functions and distacne to yvec
Ms=floor(maxsize/nobs);  % If nobs>Ms, do computations it in portions.
Ms = max(Ms,1);

loopdispflag = (Ms<ncells) && displayon;

if loopdispflag
    fprintf('Normalizing wavelets: %3d%%', 0);
end

normvk = zeros(1,ncells);
vyrate = zeros(1,ncells);
for kc=1:Ms:ncells
    jj=kc:min(ncells,kc+Ms-1);           % disp([jj(1) jj(end)])
    vk = basisfun(1, xnl, Dila(jj,:), Tran(jj,:));
    normvk1 = sqrt(sum(vk.*vk, 1));
    aby1 = abs(yvec'*vk) ./ normvk1;
    vk = basisfun(2, xnl, Dila(jj,:), Tran(jj,:));
    normvk2 =  sqrt(sum(vk.*vk, 1));
    aby2 = abs(yvec'*vk) ./ normvk2;
    normvk(jj) = min(normvk1,normvk2);
    vyrate(jj) = aby2 ./ aby1;
    
    if loopdispflag
        fprintf('\b\b\b\b%3d%%', round(kc/ncells*100));
    end
end

if loopdispflag
    fprintf('\b\b\b\b%3d%%\n',100);
end

indwave = find(normvk>=eps*max(normvk));

ncells = length(indwave); % may have been changed due to nul vectors

indscaling = find((normvk>=eps*max(normvk)) & (vyrate<1));

% number of scaling function condidates to be kept
nbscalcand = min(length(indscaling), max(10, round(ncells*0.3)));

% sort scaling functions according to their merit over wavelets
[~, indsort] = sort(vyrate(indscaling));

%indices of scaling function condidates to be kept (number=nbscalcand)
indscaling = indscaling(indsort(1:nbscalcand));


xlcol=size(xlin,2);
vcol =  ncells+length(indscaling);
qrcol = vcol+xlcol+1;  % Vc, xlin, yvec

% Compacting basis functions using QR or EIG
Ms=floor(maxsize/qrcol);  % If nobs>Ms, do computations it in portions.
Ms = max(Ms,1);

loopdispflag = (Ms<nobs) && displayon;

if loopdispflag
    fprintf('Compacting wavelets: %3d%%', 0);
end

if   nobs<=Ms  % QR is used for single block computation, otherwise EIG
    R1 = triu(qr([xlin, ...
        basisfun(1,xnl, Dila(indscaling,:),Tran(indscaling,:)), ...
        basisfun(2,xnl, Dila(indwave,:), Tran(indwave,:)), ...
        yvec]));
    
    newrows = min(qrcol, nobs);
    xlin = R1(1:newrows,1:xlcol);
    Vc = R1(1:newrows,(xlcol+1):(xlcol+vcol));
    yvec = R1(1:newrows,qrcol);
    
else  % EIG for lower computation burden
    
    R1 = zeros(qrcol,qrcol);
    for kq=1:Ms:nobs
        jj=kq:min(nobs,kq+Ms-1);     %disp([jj(1) jj(end)])
        Vbloc = [xlin(jj,:), ...
            basisfun(1,xnl(jj,:), Dila(indscaling,:),Tran(indscaling,:)), ...
            basisfun(2,xnl(jj,:), Dila(indwave,:), Tran(indwave,:)), ...
            yvec(jj,:)];
        R1 = R1 + Vbloc'*Vbloc;
        
        if loopdispflag
            fprintf('\b\b\b\b%3d%%', round(kq/nobs*100));
        end
        
    end
    [R1,DiagMat] = eig(R1);
    R1 = sqrt(max(0,DiagMat))*R1';
    xlin = R1(1:qrcol,1:xlcol);
    Vc = R1(1:qrcol,(xlcol+1):(xlcol+vcol));
    yvec = R1(1:qrcol,qrcol);
    
    clear R1 DiagMat Vbloc
end
% Note: from now on, xlin, Vc and yvec are reduced
% (equivalently left multiplied by the Q' factor of [xlin, Vc]).

if loopdispflag
    fprintf('\b\b\b\b%3d%%\n',100);
end

clear xnl vk normvk vyrate indwave indsort

ssy = yvec'*yvec;

% Before selecting basis functions candidates,
% process linear regressors first.
[Ql, Rl] = qr(xlin, 0); 
coeflin = Rl \ (Ql'* yvec);
% Note: Though the above two lines are equivalent to coeflin = xlin(1:xlcol,:)\yvec(1:xlcol); 
% the QR decomposition is necessary, since Ql will be used below.

% Linear Model Extension, part 2/3
if LmdlExtFlag
    coeflin(1) = 0;
        coeflin(2:end) =  lct \ extlin; % Careful with reduced lct
    else
  % Do this projection only when LmdlExtFlag==false. 25 Oct 2009.
QlVc = Ql' * Vc;
Vc = Vc - Ql * QlVc; % From now on, Vc is the complement of its projection to Ql.
end

yvec = yvec - xlin * coeflin;
% From now on, yvec is the residual after linear regression

clear Ql xlin xlinval xnl

if isempty(nlregs) || rank(Vc)==0 % rank(Vc)==0 for the case the linear part captures all.
    Il = [];
    allcoef = [];
    sigma2 = NaN;
    estinfo = [];
else
    % Finally call bfselect to select basis functions candidates (note: maxcells->maxUnits).
    [Il, allcoef, sigma2, estinfo] = bfselect(yvec, Vc, numunits, maxcells, ssy, nobs, displayon);
    
    if ~LmdlExtFlag  % Part 3/3 of Linear Model Extension (disable backward projection).
        coeflin = coeflin - Rl \ (QlVc(:,Il) * allcoef); % project back coeflin
    end
end

outoffset = coeflin(1) + ymean;
coeflin = coeflin(2:end);

if isempty(coeflin) %  LinearTerm='off'
    coeflin = zeros(0,1);  % Correct the empty matrix dimension
end

% To finish, get the parameters of the selected basis functions

% for scaling functions
ind = find(Il<=length(indscaling));
if isempty(ind)
    coefsc=zeros(0,1); dilasc=coefsc;  transc=zeros(0,dimxnl);
else
    coefsc = allcoef(ind);
    ind = indscaling(Il(ind));
    dilasc = Dila(ind, :);
    transc = Tran(ind, :);
end

% for wavelet functions
ind = find(Il>length(indscaling));
if isempty(ind)
    coefwl=zeros(0,1); dilawl=coefwl;  tranwl=zeros(0,dimxnl);
else
    coefwl = allcoef(ind);
    ind = Il(ind)-length(indscaling);
    dilawl = Dila(ind, :);
    tranwl = Tran(ind, :);
end

hth.RegressorMean = regmean;
hth.NonLinearSubspace = pct;
hth.LinearSubspace = lct;
hth.OutputOffset = outoffset;
hth.LinearCoef = coeflin;
hth.ScalingCoef = coefsc;
hth.WaveletCoef = coefwl;
hth.ScalingDilation = dilasc;
hth.WaveletDilation = dilawl;
hth.ScalingTranslation = transc;
hth.WaveletTranslation = tranwl;

% Set the actual NumberOfUnits
nlobj.prvNumberOfUnits =length(coefsc)+length(coefwl);

% Note: Parameters must be the last property of nlobj to be set,
% otherwise the other property settings may clear Parameters.
nlobj.Parameters = hth;

smprintf('\nNumber of selected scaling functions: %d\n', length(coefsc));
smprintf('Number of selected wavelet functions: %d\n', length(coefwl));

%===================================================================
function P = PCAProjection(x)
% PCA projection matrix
if isempty(x)
  P = [];
else
  [U, S, V] = svd(x,0);
  S = diag(S);  % now S is a vector
  mask = (S>=max(size(x))*eps(max(S))); % Thresholding
  S = S(mask);
  V = V(:,mask);
  P = V * diag(1 ./ S) * sqrt(size(x,1));
end

% Oct2009
% FILE END

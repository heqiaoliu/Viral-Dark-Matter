function [Isel, coef, sigma2, estinfo] = bfselect(y, Vc, nbw, maxUnits, ssy, nobs, dispOn)
%BFSELECT: basis function selection
%
% [Isel, coef, sigma2, estinfo] = bfselect(y, Vc, nbw, ssy, nobs, dispOn)
%
% y: N-by-1 vector
% Vc: N-by-L0 matrix, containing column vectors to be selected to match y
% nbw: specify the number of columns to be selected, integer, 'auto' or 'interactive'
% maxUnits: maximum number of selected units (max number of columns of Vc processed by
% OLS selection, extra columns being simply deleted by distance evaluation.
% ssy: sum of squared y
% nobs: number of observations (ssy and nobs concern original data, before preprocessing,
%       used here for the computation of fit only)
% dispOn: true for displaying algorithm progress
%
% Isel: indices of selected columns
% coef: coefficients of the selected columns
% sigma2: estimated noise variance
% estinfo: EstimationInfo 

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2009/05/23 08:02:45 $

% Author(s): Qinghua Zhang

[N, L0] = size(Vc); % N=Data length
Itrue = (1:L0)'; % Indexes of Vc columns

%BEGIN Normalize Vc
normVc = sqrt(sum(Vc.*Vc, 1));
Inul = find(normVc<eps*max(normVc));    %Find (almost) nul vectors for thresholding
if ~isempty(Inul)
  Itrue(Inul) = NaN;
  normVc(Inul) = NaN;
end
Vc = Vc ./ normVc(ones(N,1),:); % normalized Vc
%END Normalize Vc

L = sum(~isnan(Itrue));

M = min([L; maxUnits; N]); % M is the maximum possible selected vectors
if ~ischar(nbw)
  M = min(M, nbw);  % nbw is the specified number of basis functions
end

%Set up variables for the selection procedure
Inum = Itrue(~isnan(Itrue)); % L = length(Inum) = number of columns of P
P = Vc(:,Inum);
Q = zeros(N,M);
yq = zeros(M,1);
Isel = zeros(M,1);
Triang = zeros(M,M);

% If L>maxUnits, reduce P, in order to reduce the computational cost.
if L>maxUnits
  [tmpbuf, Inul] = sort(abs(y' * P));
  Inul = Inul(1:(L-maxUnits));
  
  Itrue(Inum(Inul)) = NaN;
  Vc(:, Inum(Inul)) = NaN;
  
  Inum = Itrue(~isnan(Itrue));
  P = Vc(:,Inum);
  % The value of L is not updated, because is no longer needed.
end
% Now the sizes of Inum and P are fixed.

Vnum = P;   % The size of Vnum and P will remain inchanged.
Inew = 1:size(Vnum,2); % Inew is the working indexes in the selection algorithms.

if dispOn
  fprintf('Selecting wavelets: %3d%%', 0);
end

if M>0
  %Select the first one
  yp = y' * P;
  [tmpbuf, ind] = max(abs(yp));
  Isel(1) = ind;        % index corresponding to Inew
  yq(1) = yp(ind);
  
  Triang(1,1) = 1;
  Q(:,1) = P(:, ind);
  
  Inew(ind) = NaN;
  Vnum(:, ind) = NaN;
  P(:, ind) = NaN;
end

invalidLastIter = 0; % will be set to 1 (integer) if last iteration is not valid.

%Selection loop
for kc=2:M
  
  if dispOn
    fprintf('\b\b\b\b%3d%%', round(kc/M*100));
  end
  
  P = P - Q(:,kc-1) * (Q(:,kc-1)' * P);
  
  normP2 = sum(P.*P, 1);
  
  Inul = find(normP2 < sqrt(eps));   %Threshold! 1e-6
  
  if ~isempty(Inul)    % Delete (almost) linearly dependent vectors
    Inew(Inul) = NaN;
    Vnum(:, Inul) = NaN;
    P(:,Inul) = NaN;
    normP2(Inul) = NaN;
    % Note: division by normP2 with NaN entries will lead to NaNs, which do
    % not disturb the max function.
  end
  
  if all(isnan(Inew)) % Terminate if no remaining linearly independent vector
    invalidLastIter = 1;    % Remove 1 from kc, since this iteration is null.
    break;
  end
  
  yp = y' * P;
  
  nextQsearch = true;
  while nextQsearch 
    % This while-loop is to jump over new Q columns not sufficiently
    % orthogonal to previous ones.
    [tmpbuf, ind] = max(yp.*yp ./ normP2);
    Isel(kc) = ind;    % index corresponding to Inew
    
    Triang(kc,kc) = sqrt(normP2(ind));
    Triang(1:(kc-1), kc) = Q(:,1:(kc-1))' * Vnum(:,ind);
    
    Q(:,kc) = P(:,ind) / Triang(kc,kc);
    
    if max((Q(:,kc)'*Q(:,1:kc-1)).^2)>eps    % Added 03/22/2002
      Inew(ind) = NaN;
      P(:,ind) = NaN;
      Vnum(:,ind) = NaN;
      normP2(ind) = NaN;
      
      if all(isnan(Inew))  % Terminate if no remaining linearly independent vector
        nextQsearch = false;
        ind = NaN; % Indicating that the for-loop should be stopped
      end
    else
       nextQsearch = false;
    end
  end
  
  if isnan(ind)
    invalidLastIter = 1;    % Remove 1 from kc, since this iteration is null.
    break;
  end
  
  yq(kc) = yp(ind) / Triang(kc,kc);   % equivalent to yq(kc) = Q(:,kc)' * y;
  Inew(ind) = NaN;
  Vnum(:, ind) = NaN;
  P(:, ind) = NaN;
  
  if all(isnan(Inew))  % Terminate if no remaining linearly independent vector
    break;
  end
end

kc = kc - invalidLastIter; % possible correction due to nul iteration

if dispOn
  fprintf('\b\b\b\b%3d%%\n',100);
end

if isempty(kc)
  kc = 1;
end
if isempty(Q)
  kc = 0;
end

% Reset the sizes of the matrices
% Q = Q(:,1:kc); % No longer used.
yq = yq(1:kc);
Isel = Isel(1:kc);
Triang = Triang(1:kc,1:kc);

resid2 = (y'*y-cumsum(yq.*yq));

Isel = Inum(Isel); % indices corresponding to original Vc

if ischar(nbw) % the number of basis functions is NOT specified.
  % Generalized Cross-Validation
  [nbf, sigma2] = LocalBforder(resid2, nobs, nbw, ssy);
else  % the number of basis functions IS specified.
  if nbw==0
    nbf = 0;
    sigma2 = y'*y/N;
  else
    % This is only to get sigma2
    [nbf, sigma2] = LocalBforder((y'*y-cumsum(yq.*yq)), nobs, nbw, ssy);
    nbf = length(yq); % specified nbf
  end
end

Isel = Isel(1:nbf);
coef = Triang(1:nbf,1:nbf) \ yq(1:nbf);

% Scale back coef
coef = coef ./ normVc(Isel)';

if nbf>0
  estinfo.LossFcn = resid2(nbf)/nobs;
  estinfo.GCV = (resid2(nbf)+2*sigma2*log10(nobs)*nbf)/nobs;
else
  estinfo.LossFcn = y'*y/nobs;
  estinfo.GCV = estinfo.LossFcn;
end
estinfo.FPE =  estinfo.LossFcn*(1+2*nbf/nobs); %(1+nbf/nobs)/(1-nbf/nobs);

%===============Local Functions============================================
function [gcv, sigma2] = LocalGCV(resid2, nobs)
%Compute GCV criterion with variance estimation
%resid2(kc) is the sum of square residuals obtained with kc basis functions
%nobs is the data sample length

np = (1:length(resid2))';

% sigma2 = median(resid2)/nobs; % Initial estimation
minval = min(resid2);
maxval = max(resid2);
margin = (maxval-minval)*0.25; 
ind1 = find(resid2<=(maxval-margin), 1, 'first');
ind2 = find(resid2>=(minval+margin), 1, 'last');
ind2 = max(ind2, ind1); % prevent the case ind1>ind2
sigma2 = median(resid2(ind1:ind2))/nobs; % Initial estimation

lastnbf = 0;

% Iterative estimation of variance
for l=1:10
  
  gcv = (resid2 + 2 * sigma2 * log10(nobs) * np ) / nobs;
  [tmpbuf, nbf] = min(gcv);
  
  sigma2 = resid2(nbf) / nobs;
  
  if nbf==lastnbf
    break
  else
    lastnbf=nbf;
  end
end

gcv = (resid2 + 2 * sigma2 * log10(nobs) * np ) / nobs;

%-----------------------------------------------------------------------------
function [nbf, sigma2] = LocalBforder(resid2, nobs, nbw, ssy)
%Determine the number of basis functions by generalized cross validation (GCV).
%
%nbf: the number of selected basis functions
%
%resid2: the sums of square errors for different number of basis functions
%nobs: the data sample length.

if any(resid2<0)
  lastpind = find(resid2>=0, 1, 'last' );
  resid2 = resid2(1:lastpind);
end

%resid2 = max(resid2, 0);  % Set to zero negative elements of resid2
%                          % (negative due to rounding errors).

[gcv, sigma2] = LocalGCV(resid2, nobs);

[tmpbuf, nbf] = min(gcv);

if ischar(nbw) && strcmpi(nbw(1),'i')   % interactive order choice
  V.sse = resid2;
  V.ssy = ssy;
  V.indexgcv = nbf;
  nbf = iduiwnet('open', V);
end

% FILE END
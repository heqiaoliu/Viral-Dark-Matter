function [fout,xout,u]=statkscompute(ftype,xi,xispecified,m,u,L,U,weight,cutoff,...
                                     kernelname,ty,yData,foldpoint,maxp)
%STATKSCOMPUTE Perform computations for kernel smoothing density
%estimation.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:16 $

[kernel,iscdf,kernelcutoff,kernelname] = statkskernelinfo(ftype,kernelname);

if isempty(cutoff)
    cutoff = kernelcutoff;
end

% Inverse cdf is special, so deal with it here
if isequal(ftype,'icdf')
    [fout,xout]=compute_icdf(xi,xispecified,m,u,L,U,weight,cutoff,...
                             kernelname,ty,yData,foldpoint,maxp);
else
    [fout,xout,u] = compute_pdf_cdf(xi,xispecified,m,L,U,weight,kernel,...
                                    cutoff,iscdf,u,ty,foldpoint);

    % If another function based on the cdf, compute it now
    if isequal(ftype,'survivor')
        fout = 1-fout;
    elseif isequal(ftype,'cumhazard')
        fout = 1-fout;
        t = (fout>0);
        fout(~t) = NaN;
        fout(t) = -log(fout(t));
    end
end

% -----------------------------
function [fout,xout,u]=compute_pdf_cdf(xi,xispecified,m,L,U,weight,...
                          kernel,cutoff,iscdf,u,ty,foldpoint)

foldwidth = min(cutoff,3);
issubdist = isfinite(foldpoint);
if ~xispecified
    xi = compute_default_xi(ty,foldwidth,issubdist,m,u,U,L);
elseif ~isvector(xi)
    error('stats:ksdensity:VectorRequired','XI must be a vector');
end

% Compute transformed values of evaluation points that are in bounds
xisize = size(xi);
fout = zeros(xisize);
if iscdf && isfinite(U)
    fout(xi>=U) = sum(weight);
end
xout = xi;
xi = xi(:);
if L==-Inf && U==Inf   % unbounded support
    inbounds = true(size(xi));
    txi = xi;
elseif L==0 && U==Inf  % positive support
    inbounds = (xi>0);
    xi = xi(inbounds);
    txi = log(xi);
    foldpoint = log(foldpoint);
else % finite support [L, U]
    inbounds = (xi>L) & (xi<U);
    xi = xi(inbounds);
    txi = log(xi-L) - log(U-xi);
    foldpoint = log(foldpoint-L) - log(U-foldpoint);
end

% If the density is censored at the end, add new points so that we can fold
% them back across the censoring point as a crude adjustment for bias.
if issubdist
    needfold = (txi >= foldpoint - foldwidth*u);
    txifold = (2*foldpoint) - txi(needfold);
    nfold = sum(needfold);
else
    nfold = 0;
end

% Compute kernel estimate at the requested points
f = dokernel(iscdf,txi,ty,u,weight,kernel,cutoff);

% If we need extra points for folding, do that now
if nfold>0
    % Compute the kernel estimate at these extra points
    ffold = dokernel(iscdf,txifold,ty,u,weight,kernel,cutoff);
    if iscdf
        % Need to use upper tail for cdf at folded points
        ffold = sum(weight) - ffold;
    end

    % Fold back over the censoring point
    f(needfold) = f(needfold) + ffold;
    
    if iscdf
        % For cdf, extend last value horizontally
        maxf = max(f(txi<=foldpoint));
        f(txi>foldpoint) = maxf;
    else
        % For density, define a crisp upper limit with vertical line
        f(txi>foldpoint) = 0;
        if ~xispecified
            xi(end+1) = xi(end);
            f(end+1) = 0;
            inbounds(end+1) = true;
        end
    end
end


if iscdf
    % Guard against roundoff.  Lower boundary of 0 should be no problem.
    f = min(1,f);
else
    % Apply reverse transformation and create return value of proper size
    f = f(:) ./ u;
    if L==0 && U==Inf   % positive support
        f = f ./ xi;
    elseif U<Inf        % bounded support
        f = f * (U-L) ./ ((xi-L) .* (U-xi));
    end
end
fout(inbounds) = f;
xout(inbounds) = xi;

% -----------------------------
function xi = compute_default_xi(ty,foldwidth,issubdist,m,u,U,L)
% Get XI values at which to evaluate the density

% Compute untransformed values of lower and upper evaluation points
ximin = min(ty) - foldwidth*u;
if issubdist
    ximax = max(ty);
else
    ximax = max(ty) + foldwidth*u;
end

if L==0 && U==Inf    % positive support
    ximin = exp(ximin);
    ximax = exp(ximax);
elseif U<Inf         % bounded support
    ximin = (U*exp(ximin)+L) / (exp(ximin)+1);
    ximax = (U*exp(ximax)+L) / (exp(ximax)+1);
end

xi = linspace(ximin, ximax, m);

% -----------------------------
function f = dokernel(iscdf,txi,ty,u,weight,kernel,cutoff)
% Now compute density estimate at selected points
blocksize = 3e4;
m = length(txi);
n = length(ty);

if n*m<=blocksize && ~iscdf
    % For small problems, compute kernel density estimate in one operation
    z = (repmat(txi',n,1)-repmat(ty,1,m))/u;
    f = weight * feval(kernel, z);
else
    % For large problems, try more selective looping

    % First sort y and carry along weights
    [ty,idx] = sort(ty);
    weight = weight(idx);

    % Loop over evaluation points
    f = zeros(1,m);

    if isinf(cutoff)
        for k=1:m
            % Sum contributions from all
            z = (txi(k)-ty)/u;
            f(k) = weight * feval(kernel,z);
        end
    else
        % Sort evaluation points and remember their indices
        [stxi,idx] = sort(txi);

        jstart = 1;       % lowest nearby point
        jend = 1;         % highest nearby point
        halfwidth = cutoff*u;
        for k=1:m
            % Find nearby data points for current evaluation point
            lo = stxi(k) - halfwidth;
            while(ty(jstart)<lo && jstart<n)
                jstart = jstart+1;
            end
            hi = stxi(k) + halfwidth;
            jend = max(jend,jstart);
            while(ty(jend)<=hi && jend<n)
                jend = jend+1;
            end
            nearby = jstart:jend;

            % Sum contributions from these points
            z = (stxi(k)-ty(nearby))/u;
            fk = weight(nearby) * feval(kernel,z);
            if iscdf
                fk = fk + sum(weight(1:jstart-1));
            end
            f(k) = fk;
        end

        % Restore original x order
        f(idx) = f;
    end
end

% -----------------------------
function [x1,p] = compute_icdf(xi,xispecified,m,u,L,U,...
    weight,cutoff,kernelname,ty,yData,foldpoint,maxp)
if xispecified
    p = xi;
else
    p = (1:m)/(m+1);
end

[Fi,xi,cutoff,u] = compute_initial_icdf(m,u,L,U,weight,cutoff,...
    kernelname,ty,yData,foldpoint);

[kernel_c,iscdf_c] = statkskernelinfo('cdf',kernelname);
[kernel_p,iscdf_p] = statkskernelinfo('pdf',kernelname);


% Get starting values for ICDF(p) by inverse linear interpolation of
% the gridded CDF, plus some clean-up
x1 = interp1(Fi,xi,p);               % interpolate for p in a good range
x1(isnan(x1) & p<min(Fi)) = min(xi); % use lowest x if p>0 too low
x1(isnan(x1) & p>max(Fi)) = max(xi); % use highest x if p<1 too high
x1(p<0 | p>maxp) = NaN;              % out of range
x1(p==0) = L;                        % use lower bound if p==0
x1(p==maxp) = U;                     % and upper bound if p==1 or other max

% Now refine the ICDF using Newton's method for cases with 0<p<1
notdone = find(p>0 & p<maxp);
maxiter = 100;
for iter = 1:maxiter
    if isempty(notdone), break; end
    x0 = x1(notdone);

    % Compute cdf and derivative (pdf) at this value
    F0 = compute_pdf_cdf(x0,true,m,L,U,weight,kernel_c,cutoff,...
                         iscdf_c,u,ty,foldpoint);
    dF0 = compute_pdf_cdf(x0,true,m,L,U,weight,kernel_p,cutoff,...
                          iscdf_p,u,ty,foldpoint);


    % Perform a Newton's step
    dp = p(notdone) - F0;
    dx = dp ./ dF0;
    x1(notdone) = x0 + dx;

    % Continue if the x and function (probability) change are large
    notdone = notdone(  abs(dx) > 1e-6*abs(x0) ...
                      & abs(dp) > 1e-8 ...
                      & x0 < foldpoint);
end
if ~isempty(notdone)
    warning('stats:ksdensity:NoConvergence',...
        'Inverse CDF calculation did not converge for p = %g.', ...
        p(notdone(1)));
end

% -----------------------------
function [Fi,xi,cutoff,u] = compute_initial_icdf(m,u,L,U,weight,cutoff,...
    kernelname,ty,yData,foldpoint)
% To get starting x values for the ICDF evaluated at p, first create a
% grid xi of values spanning the data on which to evaluate the CDF
sy = sort(yData);
xi = linspace(sy(1), sy(end), 100);

% Estimate the CDF on the grid
[kernel_c,iscdf_c,kernelcutoff] = statkskernelinfo('cdf',kernelname);

[Fi,xi,u] = compute_pdf_cdf(xi,true,m,L,U,weight,kernel_c,cutoff,...
                            iscdf_c,u,ty,foldpoint);

if isequal(kernelname,'normal')
    % Truncation for the normal kernel creates small jumps in the CDF.
    % That's not a problem for the CDF, but it causes convergence problems
    % for ICDF calculation, so use a cutoff large enough to make the jumps
    % smaller than the convergence criterion.
    cutoff = max(cutoff,6);
else
    % Other kernels have a fixed finite width.  Ignore any requested
    % truncation for these kernels; it would cause convergence problems if
    % smaller than the kernel width, and would have no effect if larger.
    cutoff = kernelcutoff;
end

% If there are any gaps in the data wide enough to create regions of
% exactly zero density, include points at the edges of those regions
% in the grid, to make sure a linear interpolation smooth of the gridded
% CDF captures them as constant
halfwidth = cutoff*u;
gap = find(diff(sy) > 2*halfwidth);
if ~isempty(gap)
    sy = sy(:)';
    xi = sort([xi, sy(gap)+halfwidth, sy(gap+1)-halfwidth]);
    [Fi,xi,u] = compute_pdf_cdf(xi,true,m,L,U,weight,kernel_c,...
                                cutoff,iscdf_c,u,ty,foldpoint);
end

% Find any regions where the CDF is constant, these will cause problems
% inverse interpolation for x at p
t = (diff(Fi) == 0);
if any(t)
    % Remove interior points in constant regions, they're unnecessary
    s = ([false t] & [t false]);
    Fi(s) = [];
    xi(s) = [];
    % To make Fi monotonic, nudge up the CDF value at the end of each
    % constant region by the smallest amount possible.
    t = 1 + find(diff(Fi) == 0);
    Fi(t) = Fi(t) + eps(Fi(t));
    % If the CDF at the point following is that same value, just remove
    % the nudge.
    if (t(end) == length(Fi)), t(end) = []; end
    s = t(Fi(t) >= Fi(t+1));
    Fi(s) = [];
    xi(s) = [];
end

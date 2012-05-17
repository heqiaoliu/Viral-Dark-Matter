function [p, h] = normspec(specs,mu,sigma,region)
%NORMSPEC Plots normal density between specification limits.
%    NORMSPEC(SPECS) plots the standard normal density, shading the
%    portion inside the spec limits.  SPECS is a two element vector
%    containing the lower and upper specification limits.
%    Set SPECS(1)=-Inf if there is no lower limit, and SPECS(2)=Inf
%    if there is no upper limit. 
% 
%    NORMSPEC(SPECS,MU,SIGMA) shades the portion inside the spec limits of
%    a normal density with parameters MU and SIGMA.  The defaults are MU=0 and
%    SIGMA=1.
% 
%    NORMSPEC(SPECS,MU,SIGMA,REGION) shades either the portion 'inside' or
%    'outside' of the spec limits.  The default is REGION='inside'.
% 
%    [P] = NORMSPEC(...) returns the probability, P, of the shaded area.
%
%    [P,H] = NORMSPEC(...) returns a handle H to the line objects.
% 

%   Copyright 1993-2009 The MathWorks, Inc. 
% $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:34 $

%fill in default args
if nargin<2
    mu=0;
end
if nargin<3
    sigma=1;
end
if nargin<4
    region='inside';
end

%test for invalid args
if numel(specs) ~= 2 || ~isnumeric(specs),
    error('stats:normspec:BadSpecs',...
        'Requires SPECS to be a two element numeric vector.');
end

if max(size(mu)) > 1 || max(size(sigma)) > 1 ,
    error('stats:normspec:ScalarRequired',...
        'Requires scalar 2nd and 3rd input arguments.');
end

if isempty(strmatch(region,{'inside','outside'},'exact'))
    error('stats:normspec:BadRegion',...
        'Requires REGION to be ''inside'' or ''outside''. ');

end

%swap the specs if they are reversed
lb = specs(1);
ub = specs(2);
if lb > ub
    lb = specs(2);
    ub = specs(1);
end
lbinf = isinf(lb);
ubinf = isinf(ub);

%continue checking for invalid args
if lbinf && ubinf
    error('stats:normspec:BadSpecs',...
        'The SPECS vector must have at least one finite element.');
end

%compute normal curve
prob = (0.0002:0.0004:0.9998)';
x = norminv(prob,mu,sigma);
y = normpdf(x,mu,sigma);

%compute p
if strcmp(region,'outside')
    if lbinf,
        p = normcdf(-ub,-mu,sigma); % P(t > ub)
    elseif ubinf,
        p = normcdf(lb,mu,sigma); % P(t < lb)
    else
        p = sum(normcdf([lb -ub],[mu -mu],sigma)); % P(t < lb) + Pr(t > ub)
    end
else
    if lbinf,
        p = normcdf(ub,mu,sigma); % P(t < ub)
    elseif ubinf,
        p = normcdf(-lb,-mu,sigma); % P(t > lb)
    else
        p = diff(normcdf([lb ub],mu,sigma)); % P(lb < t < ub)
    end
end

%get the axes ready
nspecfig = figure;
nspecaxes = axes;
set(nspecaxes, 'Parent', nspecfig);
set(nspecaxes,'Nextplot','add');

%plot the normal curve, get the x limits used by the plot
hh = plot(x,y,'b-');
xlims = get(nspecaxes,'Xlim');

%compute the endpoints of the spec limit lines and plot limit lines
%lower limit line goes up, and upper limit line goes down
pll =  [xlims(1);xlims(1)];
ypll = [0;eps];
if lbinf,
    ll =  pll;
    yll = ypll;
else
    ll =  [lb; lb];
    yll = [0; normpdf(lb,mu,sigma)];
end

pul =  [xlims(2);xlims(2)];
ypul = [eps;0];
if ubinf,
    ul =  pul;
    yul = ypul;
else
    ul  = [ub; ub];
    yul = [normpdf(ub,mu,sigma); 0];
end

%create title, draw spec lines, and shade area
switch region
    case 'inside'
        if ubinf
            str = ['Probability Greater than Lower Bound is ',num2str(p)];
            k = find(x > lb);
            hh1 = plot(ll,yll,'b-');
        elseif lbinf
            str = ['Probability Less than Upper Bound is ',num2str(p)];
            k = find(x < ub);
            hh1 = plot(ul,yul,'b-');
        else
            str = ['Probability Between Limits is ',num2str(p)];
            k = find(x > lb & x < ub);
            hh1 = plot(ll,yll,'b-',ul,yul,'b-');
        end
        xfill = [ll; x(k); ul];
        yfill = [yll; y(k); yul];
        fill(xfill,yfill,'b');
    case 'outside'
        if ubinf
            str = ['Probability Less than Lower Bound is ',num2str(p)];
            k1 = find(x < lb);
            k2=[];
            hh1 = plot(ll,yll,'b-');
        elseif lbinf
            str = ['Probability Greater than Upper Bound is ',num2str(p)];
            k1=[];
            k2 = find(x > ub);
            hh1 = plot(ul,yul,'b-');
        else
            str = ['Probability Outside Limits is ',num2str(p)];
            k1 = find(x < lb );
            k2=find(x > ub);
            hh1 = plot(ll,yll,'b-',ul,yul,'b-');
        end
        xfill = [pll;  x(k1); ll          ; ul;          x(k2); pul  ];
        yfill = [ypll; y(k1); flipud(yll) ; flipud(yul); y(k2); ypul ];
        fill(xfill,yfill,'b');
    otherwise
        error('stats:normspec:BadRegion',...
            'Requires REGION to be ''inside'' or ''outside''. ');
end

%label the plot
title(str);
xaxis = refline(0,0);
set(xaxis,'Color','k');
ylabel('Density');
xlabel('Critical Value');

%return line handles, if requested
if nargout > 1
    h = [hh; hh1];
end


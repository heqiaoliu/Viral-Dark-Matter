function c = statccconst(ctype,n,k)
%STATCCCONST Control chart constants.
%   C=STATCCCONST('CTYPE',N) computes the control chart constant of type
%   'CTYPE' for a subgroup of size N using K sigma limits.  Valid values
%   for 'CTYPE' are:  c4,d2,d3,A,A2,A3,B3,B4,B5,B6,D1,D2,D3,D4.  The
%   default value of K is 3.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:30:04 $

if nargin<3
    k = 3;   % three-sigma limits by default
end

% The following constants are used to evaluate the d2 and d3 values by
% numerical integration for n>50.  Values for n<=50 are stored in this file
% and were calculated using MAXX=10 and TOL=1e-14.  Integration with these
% values is very time consuming, so the following are adequate for most
% purposes:
MAXX = 6;
TOL = 1e-6;

% These are the pre-computed values
d2d3 = getd2d3;
nd2d3 = size(d2d3,1);

% Get d2 if needed for this ctype
if ismember(ctype, {'d2' 'A2' 'D1' 'D2' 'D3' 'D4' 'd3'})
    d2 = d2d3(min(nd2d3,max(1,n)),1);
    indx = find(n>nd2d3);
    while(~isempty(indx)) % compute values that are not pre-computed
        nn = n(indx(1));
        f = @(x) 1-localnormcdf(-x).^nn - localnormcdf(x).^nn;
        intf = quadgk(f,-MAXX,MAXX,'AbsTol',TOL,'RelTol',0);
        d2(n==nn) = intf;
        indx(n(indx)==nn) = [];
    end
end

% Get c4 if needed for this ctype
if ismember(ctype, {'c4' 'A3' 'B3' 'B4' 'B5' 'B6' 'K'})
    c4 = zeros(size(n));
    t = (n>1);
    c4(t) = sqrt(2./(n(t)-1)) .* exp(gammaln(n(t)/2) - gammaln((n(t)-1)/2));
    c4(n<1) = NaN;
end

% Get d3 if needed for this ctype
if ismember(ctype, {'d3' 'D1' 'D2' 'D3' 'D4'})
    d3 = d2d3(min(nd2d3,max(1,n)),2);
    indx = find(n>nd2d3);
    while(~isempty(indx)) % compute values that are not pre-computed
        nn = n(indx(1));
        f = @(x,y) (1-localnormcdf(-x).^nn - ...
                   localnormcdf(y).^nn + ...
                   (localnormcdf(y)-localnormcdf(x)).^nn);
        % Specify min of y as function to integrate over y>=x
        intf = quad2d(f,-MAXX,MAXX,@(x)x,MAXX,'AbsTol',TOL);
        d3(n==nn) = sqrt(max(0,2*intf - d2(indx(1))^2));
        indx(n(indx)==nn) = [];
    end

end

% Compute the requested ctype
switch(ctype)
    case 'A'
        c = k ./ sqrt(n);
    case 'A2'
        c = k ./ (d2 .* sqrt(n));
    case 'A3'
        c = k ./ (c4 .* sqrt(n));
    case 'c4'
        c = c4;
    case 'B3'
        c = max(0, 1 - k * sqrt(1-c4.^2) ./ c4);
    case 'B4'
        c = 1 + k * sqrt(1-c4.^2) ./ c4;
    case 'B5'
        c = max(0, c4 - k * sqrt(1-c4.^2));
    case 'B6'
        c = c4 + k * sqrt(1-c4.^2);
    case 'd2'
        c = d2;
    case 'd3'
        c = d3;
    case 'D1'
        c = max(0, d2 - k*d3);
    case 'D2'
        c = d2 + k*d3;
    case 'D3'
        c = max(0, 1 - k * d3 ./ d2);
    case 'D4'
        c = 1 + k * d3 ./ d2;
    otherwise
        error('stats:statccconst:BadCType','Bad CTYPE value "%s".',ctype);
end

function p = localnormcdf(z)
% local normcdf replacement to omit error checking
p = 0.5 * erfc(-z ./ sqrt(2));

function d2d3 = getd2d3
d2d3 = [0 0
1.128379167 0.8525024664
1.692568751 0.888368004
2.058750746 0.8798082028
2.325928947 0.8640819411
2.534412721 0.8480396861
2.704356751 0.8332053356
2.847200612 0.8198314898
2.970026324 0.8078342746
3.077505462 0.7970506735
3.172872704 0.7873146206
3.25845528 0.7784783412
3.335980354 0.7704162021
3.406763108 0.7630230956
3.47182689 0.7562114297
3.531982786 0.7499080894
3.587883962 0.744051784
3.640063758 0.7385908534
3.688963023 0.7334814955
3.73495012 0.7286863457
3.77833583 0.7241733407
3.819384643 0.7199148084
3.858323423 0.7158867355
3.895348148 0.7120681752
3.93062922 0.7084407659
3.96431568 0.7049883378
3.996538604 0.7016965889
4.027413848 0.6985528172
4.057044292 0.6955456983
4.085521688 0.6926650989
4.112928195 0.6899019205
4.139337656 0.6872479671
4.164816672 0.6846958331
4.189425512 0.6822388072
4.213218879 0.6798707913
4.236246574 0.6775862294
4.258554051 0.6753800471
4.28018291 0.6732475991
4.301171315 0.671184623
4.321554356 0.6691871998
4.34136437 0.6672517188
4.360631215 0.6653748465
4.379382521 0.6635535004
4.397643897 0.6617848243
4.415439128 0.6600661676
4.432790336 0.6583950665
4.449718135 0.6567692271
4.466241762 0.6551865107
4.482379194 0.6536449202
4.498147259 0.6521425884];

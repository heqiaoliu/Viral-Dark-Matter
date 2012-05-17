function mr = balred(m,order,varargin)
%MRED = BALRED(M,ORDER) computes a reduced order approximation MRED of the
%IDMODEL M.
%
%   This function requires Control System Toolbox.
%
%   M: Original model as an IDMODEL (IDPOLY, IDARX, IDPOLY, or IDGREY).
%   ORDER: Desired order of reduced model.
%      If ORDER = [] (default), a plot of Hankel singular values is shown,
%      and you are prompted to select the order. States with relatively
%      small Hankel singular values can be safely discarded. 
%
%   Property-value pairs:
%   MRED = BALRED(M,ORDER,'DISTURBANCEMODEL','NONE')
%       Produces an output error  model (K = 0); otherwise the noise model
%       is also reduced. 
%
%   MRED = BALRED(M,ORDER,PV-Pairs) 
%       Allows specification of additional options supported by the
%       LTI/BALRED function, such as 'AbsTol' and 'RelTol'. Type "help
%       lti/balred" for information on supported property-value pairs.
%
%   Note: The reduced order model as an IDSS model.
%
%   See also lti/balred, MODRED, IDMODEL, lti/hsvd.

%   L. Ljung 10-10-05
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/10/02 18:47:55 $

if ~iscstbinstalled
    ctrlMsgUtils.error('Ident:general:cstbRequired','balred')
end

if nargin<2,
    order = [];
end

if nargin>=2 && ~isempty(order) && (~isnumeric(order) || ~isscalar(order))
    ctrlMsgUtils.error('Ident:idmodel:invalidOrder')
end   

V = varargin;
if nargin>2
    %parse the property-value pair
    prop = V(1:2:end);
    if ~all(cellfun('isclass',prop,'char'))
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames');
    end

    %locate DisturbanceModel specification:
    idist = find(strncmpi(V,'d',1));
    if ~isempty(idist)
        if ischar(V{idist(end)+1}) && strncmpi(V{idist(end)+1},'n',1)
            m = m(:,'meas');
            V = V(setdiff(1:length(V),[idist idist+1]));
        else
            ctrlMsgUtils.error('Ident:idmodel:balredcheck1');
        end
    end

end

% Convert into LTI/State Space object
m1 = ss(m);

hsvpv = {};
if isempty(order)
    if nargin>2
        %locate reltol, abstol and offset
        irel = find(strncmpi(V,'r',1));
        iabs = find(strncmpi(V,'a',1));
        ioff = find(strncmpi(V,'o',1));
        try
            hsvpv = {V{irel},V{irel+1},V{iabs},V{iabs+1},V{ioff},V{ioff+1}};
        catch
            ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs','balred','idmodel/balred')
        end
    end
    [hs,baldata] = hsvd(m1,hsvpv{:});
    f = figure; %new figure for hsv plot
    hsvd(m1,hsvpv{:})
    order = input('Enter the desired order (positive scalar):   ');
    close(f);
    if isempty(order)
        ctrlMsgUtils.warning('Ident:idmodel:emptyOrder')
        mr = m;
        return;
    end
    V = {V{:},'baldata',baldata};
end

% perform balanced reduction
mred = balred(m1,order,V{:});
mr1 = idss(mred);
mr = inherit(mr1,m);


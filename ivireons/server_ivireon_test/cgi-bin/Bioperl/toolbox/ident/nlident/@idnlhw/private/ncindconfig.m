function [ncind, Bc] = ncindconfig(sys, Bc)
%NCINDCONFIG sets up non computed indices (ncind) configuration

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/06/13 15:24:24 $

% Author(s): Qinghua Zhang

[ny, nu] = size(sys);

if ny>1 && nu>1 % MIMO
    % all free
    %ncind = zeros(ny,nu);
    [ncind, Bc] = MIMOncind(sys, Bc);
    return
    
elseif ny==1 && nu==1 % SISO
    % fix if u or y free
    if isfreegain(sys.InputNonlinearity) || isfreegain(sys.OutputNonlinearity)
        ncind = 1;
    else
        ncind = 0;
    end
    
elseif ny==1 % MISO
    ncind = zeros(1,nu);
    % For each u channel, fix if free u
    for ku=1:nu
        ncind(ku) = double(isfreegain(sys.InputNonlinearity(ku)));
    end
    
    % Ignore zero nb channels when considering free y
    ncind(pvget(sys, 'nb')==0) = 1; % will be set to zero later
    
    % If free y, fix first free lin
    if isfreegain(sys.OutputNonlinearity) && any(~ncind)
        ncind(find(~ncind, 1 )) = 1;
    end
    
else %SIMO
    ncind = zeros(ny, 1);
    % For each y channel, fix if free y
    for ky=1:ny
        ncind(ky) = double(isfreegain(sys.OutputNonlinearity(ky)));
    end
    
    % If free u, fix first free lin
    if isfreegain(sys.InputNonlinearity) && any(~ncind)
        ncind(find(~ncind, 1 )) = 1;
    end
end

% Process zero nb
ncind(pvget(sys, 'nb')==0) = 0;

nk = pvget(sys, 'nk');

% Normalize B if necessary
for ky=1:ny
    for ku=1:nu
        if ncind(ky,ku)~=0
            [maxabs, nci] =  max(abs(Bc{ky,ku}));
            if nci<=nk(ky,ku)
                nci = nk(ky,ku)+1; %ncind(ky,ku)~=0 implies nb(ky,ku)~=0
                maxabs = 0;
            end
            ncind(ky,ku) = nci;
            if maxabs>eps
                Bc{ky,ku} = Bc{ky,ku} / Bc{ky,ku}(nci);
            else
                Bc{ky,ku}(nci) = 1;
            end
        end
    end
end

%==================================
function [ncind, Bc] = MIMOncind(sys, Bc)
% MIMO case

[ny, nu] = size(sys);

ncind = zeros(ny,nu);

truech = pvget(sys, 'nb')~=0; % non empty channels

yfreegains = false(ny,1);
for ky=1:ny
    yfreegains(ky) = isfreegain(sys.OutputNonlinearity(ky));
end

for ku=1:nu
    if isfreegain(sys.InputNonlinearity(ku))
        % for each UNL with free gain, find the true output channel ind
        % with fixed YNL gain
        ind = find(~yfreegains & truech(:,ku), 1 );
        if isempty(ind)
            ind = find(truech(:,ku), 1 );
        end
        if ~isempty(ind)
            ncind(ind, ku) = 1;
        end
    end
end
for ky=1:ny
    if yfreegains(ky)
        % for each YNL with free gain, find the connected true input channel ind
        % not yet fixed.
        ind = find(truech(ky,:) & (ncind(ky,:)==0), 1 );
        if ~isempty(ind)
            ncind(ky,ind) = 1;
        end
    end
end

nk = pvget(sys, 'nk');

% Normalize B if necessary
for ky=1:ny
    for ku=1:nu
        if ncind(ky,ku)~=0
            [maxabs, nci] =  max(abs(Bc{ky,ku}));
            if nci<=nk(ky,ku)
                nci = nk(ky,ku)+1; %ncind(ky,ku)~=0 implies nb(ky,ku)~=0
                maxabs = 0;
            end
            ncind(ky,ku) = nci;
            if maxabs>=eps
                Bc{ky,ku} = Bc{ky,ku} / Bc{ky,ku}(nci);
            else
                Bc{ky,ku}(nci) = 1;
            end
        end
    end
end

% FILE END

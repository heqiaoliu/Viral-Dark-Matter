function h = allpasshalfband(this,alpha0,alpha1)
%ALLPASSHALFBAND

%   Author(s): R. Losada
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2006/06/27 23:38:16 $

filtstruct = get(this, 'FilterStructure');
desmode = this.DesignMode;
[filtstruct,mfiltstruct] = ...
    determineiirhalfbandfiltstruct(this,desmode,filtstruct);


if isempty(mfiltstruct),
    a0 = [zeros(length(alpha0),1), alpha0];
    a1 = [zeros(length(alpha1),1), alpha1];

else % Interpolator or decimator
    a0 = alpha0;
    a1 = alpha1;
end

for k = 1:size(a0,1),
    coeffcell0{k} = a0(k,:);
end

for k = 1:size(a1,1),
    coeffcell1{k} = a1(k,:);
end



if isempty(mfiltstruct),
    h0 = feval(['dfilt.',filtstruct],coeffcell0{:});
    if ~isempty(a1),
        h1 = feval(['dfilt.',filtstruct],coeffcell1{:});
    end
    hd = dfilt.delay(1);

    if isempty(a1),
        % Low order designs
        hc = hd;
    else
        hc = cascade(hd,h1);
    end

    hp = parallel(h0,hc);

    hs = dfilt.scalar(.5);

    h = cascade(hp,hs);
else
    if isempty(a1),
        % Low order designs
        coeffcell1 = {1};
    end
    h = feval(['mfilt.',mfiltstruct],coeffcell0,coeffcell1);
end



% [EOF]

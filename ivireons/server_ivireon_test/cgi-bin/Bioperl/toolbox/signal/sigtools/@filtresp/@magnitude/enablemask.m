function b = enablemask(this)
%ENABLEMASK Returns true if the mask can be drawn.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.2.4.10 $  $Date: 2008/08/01 12:25:44 $

% If there is more than 1 filter, if that filter does not have maskinfo or
% if the mask info isn't for the current analysis we cannot display the
% mask.
if ~isprop(this, 'Filters')
    b = false;
    return;
end
Hd = get(this, 'Filters');

if length(Hd) == 1 && strcmpi(this.PolyphaseView, 'on') && ispolyphase(Hd.Filter)
    b = false;
    return;
end

b  = repmat(false, 1, length(Hd));

hfdfirst = [];
hfmfirst = [];

for indx = 1:length(Hd)
    Hd = get(this.Filters(indx), 'Filter');

    if isa(Hd, 'dfilt.basefilter')

        hfd = privgetfdesign(Hd);
        hfm = getfmethod(Hd);
        
        if isempty(hfdfirst)
            hfdfirst = hfd;
        end
        if isempty(hfmfirst)
            hfmfirst = hfm;
        end
    else
        hfd = [];
        hfm = [];
    end

    if isempty(hfd) || isempty(hfm)
        if isa(Hd, 'dfilt.basefilter')
            % If one of these is empty then we need to check to see if we
            % have a valid FILTDES maskinfo to work with.
            if isprop(Hd, 'MaskInfo')
                MI = get(Hd, 'MaskInfo');
                switch lower(get(this, 'magnitudeDisplay')),
                    case {'zero-phase', 'magnitude'}
                        b(indx) = any(strcmpi(MI.magunits, {'linear', 'weights'}));
                    case 'magnitude (db)'
                        b(indx) = strcmpi(MI.magunits, 'db');
                    case 'magnitude squared'
                        b(indx) = strcmpi(MI.magunits, 'squared');
                end
            end
        end
    else
        
        % If the specification are equivalent (meaning the 'Specification'
        % is the same and all of the settings are the same) and all of the
        % methods used are constrained, we can show the masks.
        [f, a] = drawmask(hfd, hfm, []);
        if isempty(f)
            b(indx) = false;
        elseif isequivalent(hfd, hfdfirst) && ...
            hfm.isconstrained == hfmfirst.isconstrained
            b(indx) = true;
        else
            b(indx) = false;
        end
    end
end

b = all(b);

% [EOF]

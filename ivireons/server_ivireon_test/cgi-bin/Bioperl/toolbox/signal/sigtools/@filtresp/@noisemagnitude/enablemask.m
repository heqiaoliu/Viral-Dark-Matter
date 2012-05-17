function b = enablemask(this)
%ENABLEMASK Returns true if the mask can be drawn.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/04/21 16:31:09 $

% If there is more than 1 filter, if that filter does not have maskinfo or
% if the mask info isn't for the current analysis we cannot display the
% mask.
if ~isprop(this, 'Filters')
    b = false;
    return;
end
Hd = get(this, 'Filters');
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
        b(indx) = false;
    else
        
        % If the specification are equivalent (meaning the 'Specification'
        % is the same and all of the settings are the same) and all of the
        % methods used are constrained, we can show the masks.
        if isequivalent(hfd, hfdfirst) && ...
            hfm.isconstrained == hfmfirst.isconstrained
            b(indx) = true;
        else
            b(indx) = false;
        end
    end
end

b = all(b);

% [EOF]

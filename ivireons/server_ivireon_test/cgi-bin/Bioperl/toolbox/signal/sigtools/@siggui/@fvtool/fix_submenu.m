function fix_submenu(this)
%FIX_SUBMENU   Fix the overlay plot submenu.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.5 $  $Date: 2006/11/19 21:46:18 $

if get(this, 'SubMenuFixed'), return; end

h = get(this, 'Handles');

ha = get(this, 'CurrentAnalysis');

if isa(ha, 'filtresp.tworesps') && strcmpi(ha.fvtool_tag, 'tworesps'),
    ha = ha.Analyses(1);
end

tag  = get(ha, 'fvtool_tag');

tags = fieldnames(h.menu.analyses);

freqtags = {'magnitude', 'phase','grpdelay','phasedelay','magestimate','noisepower'};
timetags = {'impulse', 'step'};

if isempty(tag)
    ontags = {};
else
    switch tag
        case freqtags
            ontags = intersect(tags, freqtags);
        case timetags
            ontags = timetags;
        otherwise
            ontags = {};
    end
end

for indx = 1:length(tags),
    if any(strcmpi(tags{indx}, ontags))
        enab = get(h.menu.analyses.(tags{indx}), 'Enable');
    else
        enab = 'Off';
    end
%     try
%         filtresp.tworesps(getanalysisobject(this, tag, 'new'), ...
%             getanalysisobject(this, tags{indx}, 'new'));
%         if isfield(h.menu.righthand, tags{indx}),
%             enab = this.Enable;
%         end
%         
%     catch
%         enab = 'Off';
%     end
    if isfield(h.menu.righthand, tags{indx}),
        set(h.menu.righthand.(tags{indx}), 'Enable', enab);
    end
end

set(this, 'SubMenuFixed', true);

% [EOF]

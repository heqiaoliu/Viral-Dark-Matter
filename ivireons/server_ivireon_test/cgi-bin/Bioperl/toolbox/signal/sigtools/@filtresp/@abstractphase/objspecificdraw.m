function [m, xunits] = objspecificdraw(this)
%OBJSPECIFICDRAW Draw the response

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.5.6.9 $  $Date: 2005/06/16 08:41:38 $

h = get(this, 'Handles');
h.axes = h.axes(end);

% Get the data
[Phi, W] = getphasedata(this);
if isempty(Phi),
    m = 1;
    xunits = '';
    h.line = [];
else
    [W, m, xunits] = normalize_w(this, W);

    % Convert the data to degrees if necessary.
    if strcmpi(get(this, 'PhaseUnits'), 'degrees'),
        for indx = 1:length(Phi),
            Phi{indx} = Phi{indx}*180/pi;
        end
    end

    if ishandlefield(this,'line') && length(h.line) == size(Phi{1}, 2)
        for indx = 1:size(Phi{1}, 2)
            set(h.line(indx), 'xdata',W{1}, 'ydata',Phi{1}(:,indx));
        end
    else
        h.line = freqplotter(h.axes, W, Phi);
    end
    change = true;
    t      = [];
    thresh = eps^(1/4);
    for indx = 1:length(Phi)
        PhiTest = Phi{indx}(:);
        PhiTest(isnan(PhiTest)) = [];
        PhiTest(isinf(PhiTest)) = [];
        if isempty(PhiTest) || ...
                length(Phi{indx}) > 1 && max(std(PhiTest)) > thresh || ...
                ~isempty(t) && Phi{indx}(1)-t > thresh;
            change = false;
            break;
        end
        t = Phi{indx}(1);
    end

    if change,
        G1 = Phi{1};
        G1(isnan(G1)) = [];
        G1(isinf(G1)) = [];
        set(h.axes, 'YLim', [-1 1]+G1(1,1));
    end

end

hylbl = ylabel(h.axes, getylabel(this));

if ~ishandlefield(this, 'phaseunitscsmenu')
    h.phaseunitscsmenu = contextmenu(getparameter(this, 'phaseunits'), hylbl);
end

set(this, 'Handles', h);
phasespecificdraw(this);

% [EOF]

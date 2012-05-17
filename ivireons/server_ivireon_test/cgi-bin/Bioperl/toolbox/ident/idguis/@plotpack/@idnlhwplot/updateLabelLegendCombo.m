function updateLabelLegendCombo(this)
% update quantities that are affected by change in models:
% - xlabels of step, impulse and bode axes
% - legends on all axes
% - I/O selector combos

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:42 $

this.updateCombos;

% update legends on all axes
Ax = findobj(this.MainPanels,'type','axes');

for k = 1:length(Ax)
    axtype = get(Ax(k),'user');
    if any(strcmpi(axtype,{'step','impulse','bode','pzmap'})) ||...
            strncmp(axtype,'nonlinear',9)
        this.addLegend(Ax(k));
        if ~strncmp(axtype,'nonlinear',9)
            %linear plot: needs xlabel
            if any(strcmpi(axtype,{'step','impulse'}))
                xlab = this.getXLabel('Time');
                xlabel(Ax(k),xlab);
            elseif strcmpi(axtype,'bode')
                xlab = this.getXLabel('Frequency');
                xlabel(Ax(k),xlab);
            end
        end
    end
end

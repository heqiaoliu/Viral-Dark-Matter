function draw(this)
%  DRAW draws all responses in the simview figure
%


% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:49:49 $

% Adjust styles for sinestream
if isa(this.TimePlot,'resppack.sinestreamplot')
    % Only for visible responses
    resp_ind = this.RespIndices(:);   
    for ct = 1:numel(resp_ind)
        % Turn off style listeners for efficiency
        this.TimePlot.Responses(resp_ind(ct)).StyleListener.Enabled = 'off';
        this.SpectrumPlot.Responses(resp_ind(ct)).StyleListener.Enabled = 'off';
        % Update styles
        this.TimePlot.Responses(resp_ind(ct)).Style = this.Styles(this.FreqIndices(ct));
        this.SpectrumPlot.Responses(resp_ind(ct)).Style = this.Styles(this.FreqIndices(ct));
        % Turn them back on
        this.TimePlot.Responses(resp_ind(ct)).StyleListener.Enabled = 'on';
        this.SpectrumPlot.Responses(resp_ind(ct)).StyleListener.Enabled = 'on';
    end
end
% Draw time and FFT plots
draw(this.TimePlot);
draw(this.SpectrumPlot);
% Re-adjust time limits for non-sinestream plots. This is necessary because
% timeplot's getfocus does some extra (extending horizon and such) that
% does not fit into simview.
if ~isa(this.TimePlot,'resppack.sinestreamplot')
    AxesGrid = this.TimePlot.AxesGrid;
    ax = getaxes(this.TimePlot);  % takes I/O grouping into account
    set(ax(:),'Xlim',this.TimePlot.Responses.Data.Focus);
    if strcmp(AxesGrid.YNormalization,'on')
        % Reset auto limits to [-1,1] range
        set(ax(strcmp(AxesGrid.YLimMode,'auto'),:),'Ylim',[-1.1 1.1])
    else
        % Update Y limits
        AxesGrid.updatelims('manual',[])
    end

end


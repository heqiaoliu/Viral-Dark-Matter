function close(this)
%CLOSE    Close the eye diagram GUI

%   @commscope/@eyediagramgui
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:22:43 $

if saveIfDirty(this,'closing')

    hFig = this.FigureHandle;
    set(hFig, 'Visible', 'Off');

    % Make sure that listeners don't fire.
    listeners = this.Listeners;
    fn = fieldnames(listeners);
    for p=1:length(fn)
        lh = listeners.(fn{p});
        for q=1:length(lh)
            % Once all the listeners are MCOS, we wont need this
            if ~isa(lh{q}, 'event.listener')
                lh{q}.Enable = 'off';
            else
                lh{q}.Enabled = false;
            end
        end
    end

    hComps = allchild(hFig);
    delete(hComps);

    delete(this.FigureHandle);
    delete(this);

    clear this;
end
%-------------------------------------------------------------------------------
% [EOF]

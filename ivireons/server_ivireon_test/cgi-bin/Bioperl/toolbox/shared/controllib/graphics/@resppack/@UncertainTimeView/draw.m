function draw(this,Data,NormalRefresh)
%DRAW  Draws uncertain view

%   Author(s): Craig Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2010/05/10 17:37:33 $

% Time:      Ns x 1
% Amplitude: Ns x Ny x Nu

% Input and output sizes
[Ny, Nu] = size(this.UncertainPatch);

if strcmpi(this.UncertainType,'Bounds')
    set(this.UncertainLines,'Visible','off');
    set(this.UncertainPatch,'Visible','on');
    % Redraw the patch
    if strcmp(this.AxesGrid.YNormalization,'on') || (length(Data.Data)<2)
        % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
        set(double(this.UncertainPatch),'XData',[],'YData',[],'ZData',[])
    else
        % Map data to curves
        Data.Ts = 0;
        if isequal(Data.Ts,0)
            % Plot data as a line
            Bounds = getBounds(Data);
            XData = [Bounds.Time;Bounds.Time(end:-1:1)];
            ZData = -2 * ones(size(XData));
            for ct = 1:Ny*Nu
                TempData = Bounds.LowerAmplitudeBound(:,ct);
                YData = [Bounds.UpperAmplitudeBound(:,ct);TempData(end:-1:1)];
                set(double(this.UncertainPatch(ct)), 'XData', XData, ...
                    'YData',YData,'ZData',ZData);
            end
        else
            % Discrete time system use style to determine stem or stair plot
            switch this.Style
                case 'stairs'
                    for ct = 1:Ny*Nu
                        [T,Y] = stairs(Data.Time,Data.Amplitude(:,ct));
                        set(double(this.UncertainPatch(ct)), 'XData', T, 'YData', Y);
                    end
                case 'stem'
                    % REVISIT: Not implemented yet
                    ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
                        'Stem plot is not currently implemented for this view type.')
            end
        end
    end
else
    set(this.UncertainLines,'Visible','on');
    set(this.UncertainPatch,'Visible','off');
    if strcmp(this.AxesGrid.YNormalization,'on') || (length(Data.Data)<2)
        % RE: Defer to ADJUSTVIEW:postlim for normalized case (requires finalized X limits)
        set(double(this.UncertainLines),'XData',[],'YData',[],'ZData',[])
    else
        % Map data to curves
        Data.Ts = 0;
        RespData = Data.Data;
        if isequal(Data.Ts,0)
            for ct = 1:Ny*Nu
                % Plot data as a line
                YData = [];
                XData = [];
                for ct1 = 1:length(RespData)
                    YData = [YData; RespData(ct1).Amplitude(:);NaN];
                    XData = [XData; RespData(ct1).Time(:);NaN];
                end
            end
        end
        set(double(this.UncertainLines),'XData',XData,'YData',YData,'ZData',-2 * ones(size(XData)))
    end
end




      

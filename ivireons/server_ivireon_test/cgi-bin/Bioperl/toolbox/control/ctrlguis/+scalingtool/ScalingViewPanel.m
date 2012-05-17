classdef ScalingViewPanel < handle
    % @ScalingViewPanel class definition

    %   Author(s): P. Gahinet, C. Buhr
    %   Copyright 1986-2010 The MathWorks, Inc.
    %	 $Revision: 1.1.6.6 $  $Date: 2010/05/10 16:58:47 $
    properties (SetObservable = true)
        System
        PlotFocus = []; % empty is auto
        PlotFocusMode = 'auto';
        ScaleFocus = []; % empty is auto
        ScaleFocusMode = 'auto';
        Parent
        HG
        AxesXLimListener
        LinkXLim
    end

    methods

        function this = ScalingViewPanel(Parent)
            % Constructor
            this.Parent = Parent;
            % Build GUI components
            build(this)

            % Lay things out
            layout(this)

            %
            this.LinkXLim = linkprop(this.HG.Axes,'XLim');
            ax = handle(this.HG.Axes(1));
            this.AxesXLimListener = addlistener(ax,'XLim',...
                'PostSet',@(x,y) localUpdatePlotFocus(this));

        end

        function setPlotFocus(this,NewPlotFocus,modeflag)
            if nargin == 2
                modeflag = true;
            end
            % Revisit Validate
            this.PlotFocus = NewPlotFocus;
            if modeflag
                this.PlotFocusMode = 'manual';
            end
            update(this);
        end

        function setPlotFocusMode(this,NewPlotFocusMode)
            % Revisit Validate
            this.PlotFocusMode = NewPlotFocusMode;
            update(this);
        end
        
        function Value = getPlotFocus(this)
            Value = this.PlotFocus;
        end
        
        function Value = getPlotFocusMode(this)
            Value = this.PlotFocusMode;
        end
        
        function setScaleFocus(this,NewScaleFocus)
            % Revisit Validate
            this.ScaleFocus = NewScaleFocus;
            if ~isempty(NewScaleFocus)
                this.ScaleFocusMode = 'manual';
            else
                this.ScaleFocusMode = 'auto';
            end
            update(this);
        end
        
        function setScaleFocusMode(this,NewScaleFocusMode)
            % Revisit Validate
            this.ScaleFocusMode = NewScaleFocusMode;
            if strcmp(NewScaleFocusMode,'auto')
                this.ScaleFocus = [];
            end 
            update(this);
        end
        
        function Value = getScaleFocus(this)
            Value = this.ScaleFocus;
        end
        
        function Value = getScaleFocusMode(this)
            Value = this.ScaleFocusMode;
        end

        function setSystem(this,Target,ScaleFocus)
            % Revisit check on setting this.System to a single model
            if nargin > 2 && ~isempty(ScaleFocus)
                this.ScaleFocus = ScaleFocus;
                this.ScaleFocusMode = 'manual';
            else
                this.ScaleFocus = [];
            end
            this.PlotFocus = [];
            this.System = Target;
            update(this)

        end


        function update(this)
            %Revisit case where system is not a SS model
            % Update plot content
            sys = this.System;
            if isempty(this.System)
                return;
            end
            sw = warning('off'); [lw,lwid] = lastwarn; %#ok<WNOFF>

            % Original realization
            [a0,b0,c0,d0,junk,Ts] = dssdata(sys);
            e0 = sys.e;

            % Scaled realization
            if strcmpi(this.ScaleFocusMode,'auto') || isempty(this.ScaleFocus)
                [a,b,c,e] = xscale(a0,b0,c0,d0,e0,Ts,'Focus',[]);
            else
                [a,b,c,e] = xscale(a0,b0,c0,d0,e0,Ts,'Focus',this.ScaleFocus);
            end
            ScaledSys = ss(a,b,c,d0,Ts,'e',e,'Scaled',true);

            % Peak gain response
            if  strcmpi(this.PlotFocusMode,'auto') || isempty(this.PlotFocus) 
                [sv,w] = sigma(ScaledSys);
            else
                [sv,w] = sigma(ScaledSys,{this.PlotFocus(1) this.PlotFocus(2)});
            end
            this.PlotFocus = [w(1),w(end)];
            
            
            % Compute accuracy before and after scaling
            if Ts==0
                s = 1i*w;
            else
                s = exp(1i*w*Ts);
            end
            RelAcc0 = localComputeAccuracy(a0,b0,c0,d0,e0,s);
            RelAcc = localComputeAccuracy(a,b,c,d0,e,s);
            warning(sw); lastwarn(lw,lwid);

            % Compute optimal sensitivity to orthogonal transformation at each freq
            wopt = logspace(log10(w(1)),log10(w(end)),30);
            RelAccOpt = eps * optsens(a0,b0,c0,d0,e0,Ts,wopt);
            
            if isobject(this.AxesXLimListener)
                this.AxesXLimListener.Enabled = false;
            else
                this.AxesXLimListener.Enabled = 'off';
            end
            % Plot singular value data
            Axes = this.HG.Axes;
            cla(Axes(1));
            line('Parent',Axes(1),'Xdata',w,'Ydata',20*log10(sv(1,:)),'Color','b','LineWidth',2);
            set(Axes(1),'XLim',[w(1),w(end)],'YLimMode','auto');

            % Plot relative accuracy
            cla(Axes(2));
            L1 = line('Parent',Axes(2),'Xdata',w,'Ydata',RelAcc0,...
                'Color',[.9 .1 0],'LineStyle','--','LineWidth',2,...
                'DisplayName',ctrlMsgUtils.message('Control:scalegui:strOriginal'));
            L3 = line('Parent',Axes(2),'Xdata',w,'Ydata',RelAcc,...
                'Color','b','LineWidth',2,'DisplayName',ctrlMsgUtils.message('Control:scalegui:strScaled'));
            L2 = line('Parent',Axes(2),'Xdata',wopt,'Ydata',RelAccOpt,...
                'Color',[.7 .3 0],'LineStyle','--','LineStyle','--','LineWidth',2,...
                'DisplayName',ctrlMsgUtils.message('Control:scalegui:strPointwiseOptimal'));

            set(Axes(2),'XLim',[w(1),w(end)],'YLimMode','auto');
            
            if isobject(this.AxesXLimListener)
                this.AxesXLimListener.Enabled = true;
            else
                this.AxesXLimListener.Enabled = 'on';
            end
            legend(Axes(2),'show')
        end


        function layout(this)
            % Lays GUI components out
            HG = this.HG;
            p = get(HG.Panel,'Position');
            fw = p(3);  fh = p(4);
            hBorder = 2; vBorder = .5;
            bh = 1.5;

            y0 = vBorder;
            bw = 16;

%             % Position axes
            y0 = y0;  yh = fh-y0;   axh = 0.5*yh;
            set(HG.Axes(2),'OuterPosition',[-1 y0 fw+4 axh+2]);
            y0 = y0 + axh;
            set(HG.Axes(1),'OuterPosition',[-1 y0 fw+4 yh-axh]);
        end


        function close(this)
            delete(this.Parent)
            delete(this)
        end

    end


    methods (Access = private)
        function build(this,variant)
            % Builds GUI
            Color = get(0,'DefaultUIControlBackground');
            Panel = uipanel('Parent',this.Parent,'ForegroundColor',Color);
            HG.Panel = Panel;
            set(Panel,'units','character')

            % Axes
            ax1 = axes('Parent',Panel,'Units','character','FontSize',8,...
                'XGrid','on','Ygrid','on','Xscale','log','Yscale','linear');
            set(get(ax1,'Ylabel'),'String', ...
                ctrlMsgUtils.message('Control:scalegui:MagLabel'), ...
                'Fontsize',8)
            set(get(ax1,'Title'),'String', ...
                ctrlMsgUtils.message('Control:scalegui:FreqRespGainLabel'),...
                'Fontsize',8,'FontWeight','bold')
            ax2 = axes('Parent',Panel,'Units','character','FontSize',8,...
                'XGrid','on','Ygrid','on','Xscale','log','Yscale','log');
            set(get(ax2,'Xlabel'),'String',...
                ctrlMsgUtils.message('Control:scalegui:FreqLabel'),'Fontsize',8)
            set(get(ax2,'Ylabel'),'String', ...
                ctrlMsgUtils.message('Control:scalegui:RelAccuracyLabel'),'Fontsize',8)
            set(get(ax2,'Title'),'String', ...
                ctrlMsgUtils.message('Control:scalegui:FreqRespAccuracyLabel'),...
                'Fontsize',8,'FontWeight','bold')
            HG.Axes = [ax1 ax2];

            this.HG = HG;
        end


    end
end

%--------------------------------------------------------------------------
function RelAcc = localComputeAccuracy(a,b,c,d,e,s)
% Loop over each frequency
nw = length(s);
RelAcc = zeros(1,1,nw);
if isempty(e)
    nrme = 0;
else
    nrme = norm(e);
end
nrma = norm(a);
nrmb = norm(b);
nrmc = norm(c);
nrmd = norm(d);

% BALANCE to avoid loss of accuracy in FRKERNEL
[a,b,c,e,sf] = aebalance(a,b,c,e,'fullbal');
for ct=1:nw
   % Compute kernel info
   [h,beta,gamma] = frkernel(a,b,c,d,e,s(ct));
   if hasInfNaN(h)
      RelAcc(ct) = NaN;
   else
      nrmh = norm(h);
      beta = norm(lrscale(beta,sf,[]));
      gamma = norm(lrscale(gamma,[],1./sf));
      
      % Store sensitivity data
      sigma = nrmd + gamma * nrmb + nrmc * beta + (abs(s(ct))*nrme+nrma) * (gamma * beta);
      RelAcc(ct) = eps * sigma / nrmh;
   end
end
end

function localUpdatePlotFocus(this)
this.PlotFocus = get(this.HG.Axes(1),'Xlim');
this.PlotFocusMode = 'manual';
end
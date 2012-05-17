function generatePZPlot(this)
% generate I/O pz maps for linear models

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/08/01 12:22:58 $

v = this.Current.LinearComboValue;
unames = this.IONames.u;
ynames = this.IONames.y;
u2 = this.MainPanels(end);
unitcircle = exp(i*2*pi*(0:100)/99);
if this.isDark
    col = 'w:';
else
    col = 'k:';
end

if ~this.isGUI && (v==1)
    % we have multiple inputs/outputs option in combo
    isSinglePlot = false;
else
    isSinglePlot = true;
end

if isSinglePlot
    n = 1;
    [uname,yname] = this.decipherIOPair(v);
    unames = {uname}; ynames = {yname};
    %unames = unames(un); ynames = ynames(yn);
end

L = length(this.ModelData);
z = cell(1,L);
p = cell(1,L);
for k = 1:L
    linmod = getlinmod(this.ModelData(k).Model);
    if isempty(this.ModelData(k).Data.PZMap.z) && isempty(this.ModelData(k).Data.PZMap.p)
        [z{k},p{k}] = zpkdata(linmod);
        this.ModelData(k).Data.PZMap = struct('z',{z{k}},'p',{p{k}});
    else
        z{k} = this.ModelData(k).Data.PZMap.z;
        p{k} = this.ModelData(k).Data.PZMap.p;
    end
end

% populate axes
k = 1;
ny = length(ynames);
nu = length(unames);
for ky = 1:ny
    for ku = 1:nu
        axk = subplot(ny,nu,k,'parent',u2);
        this.initializeAxes(axk,'pzmap');
        %set(this.Figure,'CurrentAxes',axk); this.Current.AxesHandle = axk;
        %set(axk,'ButtonDownFcn',@(es,ed)this.axesBtnDownFunction);

        % Ind are indices (i,j) of the current I/O pair in models
        [models, Ind] = this.findModelsWithChannel(unames{ku},ynames{ky});

        Lm = length(models);
        Lines = zeros(1,2*Lm);
        for km = 1:Lm
            mInd = find(this.ModelData==models(km));
            Indkm = Ind(km,:);
            zz = z{mInd}{Indkm(2),Indkm(1)};
            pp = p{mInd}{Indkm(2),Indkm(1)};
            if this.isGUI
                Lines(2*km-1:2*km) = plot(axk,real(zz),imag(zz),'o',...
                    real(pp),imag(pp),'x',...
                    'Color',models(km).Color,'tag',models(km).ModelName);
                if ~models(km).isActive
                    set(Lines(2*km-1:2*km),'visible','off');
                end
            else
                Lines(2*km-1:2*km) = plot(axk,real(zz),imag(zz),models(km).StyleArg{:},...
                    real(pp),imag(pp),models(km).StyleArg{:},...
                    'tag',models(km).ModelName,'vis','off');
                set(Lines(2*km-1),'LineStyle','none','Marker','o','vis','on')
                set(Lines(2*km),'LineStyle','none','Marker','x','vis','on')
            end
            hold(axk,'on')
        end
        circ = plot(axk,real(unitcircle),imag(unitcircle),col,'tag','unit circle');
        hold(axk,'off')

        title(axk,sprintf('To %s',ynames{ky}));
        ylabel(axk,sprintf('From %s',unames{ku}));
        
        setAllowAxesRotate(rotate3d(this.Figure),axk,false);
        set(axk,'parent',u2,'tag',[unames{ku},':',ynames{ky}],'userdata','pzmap',...
            'ButtonDownFcn',@(es,ed)this.axesBtnDownFunction(axk,'pzmap'));
       
        this.addLegend(axk);
        if ~isSinglePlot && (ny*nu)>4
            legend(axk,'off')
        end
        
        k = k+1;
    end
end


function this = delayestim(Caller,Data,Orders)
% delayestim constructor
% Data: iddata object
% Orders: a cell array {na,nb}; For idnlhw models, na := nf. 

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:50:40 $

this = nlutilspack.delayestim;
this.Data.EstData = Data;
this.Caller = Caller;

z = Data;
ne = size(Data,'ne');
if ne>1 
    z = getexp(Data,this.Current.ExpNumber);
    this.Data.isMultiExp = true;
    Ts = pvget(Data,'Ts');
    if ~isequal(Ts{:})
        ctrlMsgUtils.error('Ident:idguis:unequalTs')
    end
end

this.Current.WorkingData = z(:,this.Current.OutputNumber,this.Current.InputNumber);

if isempty(Data.TimeUnit)
    this.Data.TimeUnit = 's';
else
    this.Data.TimeUnit = Data.TimeUnit;
end

if nargin>2
    this.Data.Orders = struct('na',Orders{1},'nb',Orders{2});
end

wb = waitbar(0.5,'Launching Input Delay Inspection Tool ...');
this.createLayout;

% combo boxes
set(this.UIs.uCombo,'String',get(Data,'inputnames'));
set(this.UIs.yCombo,'String',get(Data,'outputnames'));

this.draw;
this.attachListeners;

%set(this.Figure,'UserData',this);
if idIsValidHandle(wb), waitbar(1,wb,'Done.'), end
set(this.Figure,'vis','on');

%set(uigettoolbar(this.Figure,'Annotation.InsertLegend'),'state','off');
%legtoolb = uigettoolbar(this.Figure,'Annotation.InsertLegend'); 
%set(legtoolb,'state','on','ClickedCallBack','','OnCallback','legend(gca,''show'')',...
 %   'OffCallback','legend(gca,''hide'')');

if idIsValidHandle(wb), close(wb), end


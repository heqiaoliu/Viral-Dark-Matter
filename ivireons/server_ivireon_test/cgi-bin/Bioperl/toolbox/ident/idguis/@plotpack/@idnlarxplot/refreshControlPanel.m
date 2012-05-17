function changed = refreshControlPanel(this,retainRegNames)
% refresh the uicontrols in control panel for the currently selected
% output.
% retainRegNames: if true (default), try to retain the existing regressor
% names selected in the two combo boxes.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:50:59 $

if nargin<2
    retainRegNames = true;
end

thisy = this.getCurrentOutput;
robj = find(this.RegressorData,'OutputName',thisy);

% current output label
set(this.UIs.CurrentOutputLabel,'string',sprintf('Output: %s',thisy),'fontweight','bold');

regnames = robj.ActiveRegressors;

if retainRegNames
    % cache currently selected regressor names
    oldreglist = get(this.UIs.Reg2Combo,'string'); %second combo list
    reg1name =  oldreglist{get(this.UIs.Reg1Combo,'value')+1}; %robj.RegInfo(robj.ComboValue.Reg1).Name;
    reg2name =  oldreglist{get(this.UIs.Reg2Combo,'value')};
else
    reg1name = regnames{robj.ComboValue.Reg1};
    if ~robj.is2D
        reg2name = regnames{robj.ComboValue.Reg2-1};
    else
        reg2name = '<none>'; % this is not required
    end
end

Ind1 = find(strcmp(regnames,reg1name));
if ~robj.is2D
    Ind2 = find(strcmp(regnames,reg2name))+1;
else
    Ind2 = 1;
end

[Ind1,Ind2,changed] = localUpdateIndices(Ind1,Ind2,length(regnames));

if Ind2~=1
    robj.is2D = false;
end

robj.ComboValue.Reg1 = Ind1;
robj.ComboValue.Reg2 = Ind2;

% reg1 index and range
set(this.UIs.Reg1Combo,'String',regnames,'Value',robj.ComboValue.Reg1);
set(this.UIs.Reg1RangeEdit,'String',this.getRegStr(thisy,1)); 

% reg 2 index and range
set(this.UIs.Reg2Combo,'String',['<none>';regnames],'Value',robj.ComboValue.Reg2);
set(this.UIs.Reg2RangeEdit,'String',this.getRegStr(thisy,2));

set(this.Figure,'units','char'); %todo: remove this from all methods (g334994)

if (robj.ComboValue.Reg2==1)
    set(this.UIs.Reg2RangeEdit,'Enable','off');
else
    set(this.UIs.Reg2RangeEdit,'Enable','on');
end

%--------------------------------------------------------------------------
function [Ind1,Ind2,changed] = localUpdateIndices(Ind1,Ind2,N)
% N = length of regressor list
% Ind1: index of regressor 1 (first combo)
% Ind2: index of regressor 2 (second combo)
% changed: true if any of the indices are changed

changed = true;

if ~isempty(Ind1) && ~isempty(Ind2)
    changed = false;
    return;
elseif  ~isempty(Ind1) && isempty(Ind2)
    if N>1
        Ind2 = 2;
        if (Ind2==(Ind1+1))
            Ind2 = 3;
        end
    else
        % 2D plot
        Ind2 = 1;
    end
elseif isempty(Ind1) && ~isempty(Ind2)
    Ind1 = 1;
    if (Ind1==(Ind2-1))
        if N>1
            Ind1 = 2;
        else
            Ind2 = 1; %make it a 2D plot if only one reg
        end
    end
elseif isempty(Ind1) && isempty(Ind2)
    Ind1 = 1;
    if N>1
        Ind2 = 3;
    else
        % 2D plot
        Ind2 = 1;
    end
end

function str = getRegStr(this,yname,Ind)
% return a string of regressor range to display in the edit box
% Ind should be 1 (for Reg1) or 2 (for Reg2).

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:52:19 $

Data = find(this.RegressorData,'OutputName',yname);
Datacell = struct2cell(Data.RegInfo);
if Ind==1
    reg1list = get(this.UIs.Reg1Combo,'string');
    reg1name = reg1list{Data.ComboValue.Reg1};
    %reg1 = Data.RegInfo(Data.ComboValue.Reg1);
    reg1 = Data.RegInfo(strcmp(squeeze(Datacell(1,:,:)),reg1name));
    str = sprintf('[%s]',num2str(reg1.Range));
else    
    k = Data.ComboValue.Reg2;
    if k==1
        str = ''; %"none"
    else
        reg2list = get(this.UIs.Reg2Combo,'string');
        reg2name = reg2list{Data.ComboValue.Reg2};
        %reg2 = Data.RegInfo(k-1);
        reg2 = Data.RegInfo(strcmp(squeeze(Datacell(1,:,:)),reg2name));
        str = sprintf('[%s]',num2str(reg2.Range));
    end
end

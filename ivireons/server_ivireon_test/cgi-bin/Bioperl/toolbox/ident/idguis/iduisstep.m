function iduisstep(arg)
%IDUISSTEP Handles the dialog for step size in transient response

%   L. Ljung 9-27-06
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:30:12 $

Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');
lf = gcf;
men = findobj(lf,'tag','stepsize');
if strcmp(arg,'def')
    set(men,'Label','Step Size (0 -> 1)')
    opt = get(XID.plotw(5,2),'userdata');
    opt = str2mat(opt(1:3,:),int2str(0),int2str(1));
    set(XID.plotw(5,2),'userdata',opt);
    set(Xsum,'Userdata',XID);
elseif strcmp(arg,'set')
    opt = get(XID.plotw(5,2),'userdata');
    answer = inputdlg({'Enter start level:','Enter end level:'},'Step Levels',1,{opt(4,:),opt(5,:)});
    if ~isempty(answer)
     if length(eval(answer{2}))>1 || length(eval(answer{2}))>1
         errordlg('Enter only one number for each level', 'Wrong Values', 'Modal');
         return
     end
        opt = str2mat(opt(1:3,:),answer{1},answer{2});
        set(XID.plotw(5,2),'userdata',opt);
        set(Xsum,'Userdata',XID);
        str = [answer{1},' ->',answer{2}];
        set(men,'Label',['Step Size (',str,')'])
    end
end

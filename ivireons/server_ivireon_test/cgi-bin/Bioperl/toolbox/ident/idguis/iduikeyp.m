function iduikeyp
%IDUIKEYP The ident keypress function callback.

%   L. Ljung 9-27-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2006/06/20 20:08:50 $

%global XID.hw
Xsum = getIdentGUIFigure;
XID = get(Xsum,'Userdata');

if gcf~=get(0,'pointerwindow')
    return
end
usd=get(XID.hw(3,1),'userdata');
ch=get(gcf,'CurrentCharacter');
if isempty(ch), ch=' ';end
if any(ch==['s','c','q','d','m'])
    iduistat('Key press acknowledged, compiling...')
    if ch=='s',
        if isempty(usd)
            errordlg('You must first import a data set.','Error Dialog','modal');
            iduistat('');return
        end
        eval('iduinpar(''spa'');')
    elseif ch=='c'
        if isempty(usd)
            errordlg('You must first import a data set.','Error Dialog','modal');
            iduistat('');return
        end
        eval('iduinpar(''cra'');')
    elseif ch=='q'
        if isempty(usd)
            errordlg('You must first import a data set.','Error Dialog','modal');
            iduistat('');return
        end
        eval('iduiqs')
    elseif ch=='d'
        %     eval('iduifile(''load_iodata'');')
        iduifile('load_iodata','object');iduistat('')
    elseif ch=='m'
        eval('iduifile(''load_model'');'),iduistat('')
    end
else
    iduistat(['The character ',ch,' is not a valid hotkey'])
end

function ident(sessname,pathname)
%IDENT  Launches the System Identification Tool GUI.
%
% System Identification Tool provides an interactive environment for
% data analysis, model estimation and response visualization. Using 
% this GUI, a variety of models (non-parametric, and linear/nonlinear
% parametric) can be estimated and their responses visualized and compared
% to each other. The GUI facilitates estimation of both continuous-time and
% discrete-time models, using both time and frequency-domain data. Start by
% opening the GUI and importing data sets.
%
% Calling syntax:
%   IDENT opens a blank session of System Identification Tool, if the GUI
%   is not already open. Otherwise, it brings the GUI's main window into
%   focus.
%
%   IDENT(SESSION) opens System Identification Tool with the chosen session
%   file (*.sid) loaded into the GUI. SESSION file is produced as a result
%   of saving a running session of the GUI. It contains the set of data
%   objects, models and layout settings in use at the time of saving. 
%   If the GUI is already open, IDENT(SESSION) merges the contents of the
%   new session file with those already present in the GUI. 
%  
%   IDENT(SESSION,PATH) allows specification of path for SESSION file if
%   the desired session file is not on MATLAB path.
%
% System Identification Tool can also be opened using the MATLAB start
% menu, by using the Start->Toolboxes->System Identification->System
% Identification Tool option. To view the documentation reference page for
% the GUI, type "doc ident/ident".
%
% See also idhelp, idprops, iddata, idmodel, pem, arx, nlarx, nlhw, bode, step.

%   L. Ljung 4-4-94, Rajiv Singh 11/09/07
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.13.4.6 $  $Date: 2009/03/23 16:37:48 $


Xfake = findobj(allchild(0),'flat','tag','sitb16','name','FAKE');
if ~isempty(Xfake)
    close(Xfake);
end
XIDmain_win=getIdentGUIFigure;

if isempty(XIDmain_win)
    fprintf('Opening System Identification Tool .')
    if exist('idprefs.mat','file')
        load idprefs %loads XID* 
        XID.sessions = XIDsessions; %#ok<NODEF>
        XID.layout = XIDlayout; %#ok<NODEF>
        try
            XID.laypath = which('idprefs.mat');
            XID.laypath = XID.laypath(1:end-11);
        catch
            XID.laypath = XIDlaypath;
        end
        try
            XID.plotprefs = XIDplotprefs;
            XID.styleprefs = XIDstyleprefs;
        catch
            XID.plotprefs =[];
            XID.styleprefs = [];
        end
        [nr,nc]=size(XID.sessions);
        if nr<8
            pn1 = which('iddata1.sid'); pn1 = pn1(1:end-11);
            pn2 = which('iddata7.sid'); pn2 = pn2(1:end-11);
            pn3 = which('dryer.sid'); pn3 = pn3(1:end-9);
            pn4 = which('steam.sid'); pn4 = pn4(1:end-9);
            XID.sessions=str2mat('iddata1.sid',pn1,'iddata7.sid',...
                pn2,...
                'dryer.sid',pn3,'steam.sid',pn4);
        end
    else
        XID.laypath=which('startup');
        XID.layout=[];XID.styleprefs=[];XID.plotprefs=[];
        pn1 = which('iddata1.sid'); pn1 = pn1(1:end-11);
        pn2 = which('iddata7.sid'); pn2 = pn2(1:end-11);
        pn3 = which('dryer.sid'); pn3 = pn3(1:end-9);
        pn4 = which('steam.sid'); pn4 = pn4(1:end-9);
        XID.sessions=str2mat('iddata1.sid',pn1,'iddata7.sid',...
            pn2,...
            'dryer.sid',pn3,'steam.sid',pn4);
        err=0;
        lx=length(XID.laypath);
        if lx<10
            err=1; XID.laypath=[];
        else
            XID.laypath=XID.laypath(1:lx-9);
            XIDsessions = XID.sessions;
            XIDlaypath = XID.laypath;
            XIDlayout = XID.layout;
            XIDplotprefs = XID.plotprefs;
            XIDstyleprefs = XID.styleprefs;
            eval(['save ',XIDlaypath,...
                'idprefs.mat XIDlaypath XIDsessions XIDlayout ',...
                'XIDstyleprefs XIDplotprefs'],'err=1;')
            testlay = exist('idprefs.mat','file');
            if ~testlay && ~err,
                err=1;
                delete([XIDlaypath,'idprefs.mat']);
                %eval(['delete ',XIDlaypath,'idprefs.mat']);
            end
        end
        if err==0
            wtext=str2mat('',['Created preference file ',...
                XIDlaypath,'idprefs.mat.'],...
                'Type HELP MIDPREFS if you want to move this file.');
            disp(wtext)
            % $$$       else
            % $$$          wtext=str2mat('',...
            % $$$                'Warning: Could not find idprefs.mat and could not create',...
            % $$$                '         PrefDir/idprefs.mat',...
            % $$$                ['You may ignore this warning or type HELP',...
            % $$$                ' MIDPREFS for your options.']);
            % $$$          disp(wtext)
        end
    end

    zzz=rand(100,2);
    tic,arx(zzz,[4 4 1]);t=toc;
    XID.counters(6)=t/2;
    sumboard(XID);
    %idmwwb(1);iduidrop;
else
    figure(XIDmain_win)
end
if nargin>0
    try
        pkt = findstr(sessname,'.');
        if isempty(pkt)
            sessname = [sessname,'.sid'];
        end
        if nargin<2,
            pathname = which(sessname);
            pathname = pathname(1:end-length(sessname));
        end

        iduisess('load',pathname,sessname);
    catch
        errordlg(['Input to the "ident" command must represent a valid session file (*.sid) name. ',...
            'Specify path as second input if the session file is not on MATLAB path.'],...
            'Error Dialog','modal')
    end
end

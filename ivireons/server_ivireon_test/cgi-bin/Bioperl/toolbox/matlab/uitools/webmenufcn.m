function webmenufcn(webmenu, cmd)
%WEBMENUFCN Implements the figure web menu.
%  WEBMENUFCN(CMD) invokes web menu command CMD on figure GCBF.
%  WEBMENUFCN(H, CMD) invokes insert menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%
%   MathWorksHome
%   Products
%   TechSupport
%
%   Login
%   Trials
%
%   MATLABCentral
%   FileExchange
%   NewsgroupAccess
%   Newsletters
%
%   StudentRegistration
%   WebStore
%
%   CheckUpdates

%  CMD Values For Internal Use Only:
%    WebmenuPost

%  Copyright 1984-2010 The MathWorks, Inc.

error(nargchk(1,2,nargin))

if ischar(webmenu)
    cmd = webmenu;
    %webmenu = gcbo;
    %hfig = gcbf;
end

switch lower(cmd)
    case 'webmenupost'
        % FOR INTERNAL USE.
        if ~isstudent
            if ~isempty(gcbo)
                set(findobj(allchild(gcbo),'tag','figMenuWebStudentAccount'), 'visible','off');
                set(findobj(allchild(gcbo),'tag','figMenuWebStudentCenter'), 'visible','off');
                set(findobj(allchild(gcbo),'tag','figMenuWebStudentFAQ'), 'visible','off');                
                set(findobj(allchild(gcbo),'tag','figMenuWebStore'),  'visible','off');
            end
        else
            if ~isempty(gcbo)
                set(findobj(allchild(gcbo),'tag','figMenuWebLogin'), 'visible','off');
            end
        end
    case 'mathworkshome'
        web http://www.mathworks.com/pl_homepage -browser;
    case 'products'
        if isstudent
            web http://www.mathworks.com/pl_studentversion -browser;
        else
            if isJapanese()
                web http://www.mathworks.com/jp_products -browser;
            else
                web http://www.mathworks.com/pl_products -browser;
            end
        end
    case 'login'
        if isJapanese()
            web http://www.mathworks.co.jp/accesslogin/index_new.jsp?uri=http://www.mathworks.co.jp/accesslogin/myAccount.do -browser;
        else
            web http://www.mathworks.com/pl_accesslogin -browser;
        end
    case 'trials'
        web http://www.mathworks.com/pl_trials -browser;
    case 'techsupport'
        if isJapanese()
            web http://www.mathworks.com/jp_support -browser;
        else
            web http://www.mathworks.com/pl_support -browser;
        end
    case 'training'
        if isJapanese()
            web http://www.mathworks.com/jp_training -browser;
        else
            web http://www.mathworks.com/pl_training -browser;
        end
    case 'matlabcentral'
        web http://www.mathworks.com/pl_mlc -browser;
    case 'fileexchange'
        web http://www.mathworks.com/pl_fileexchange -browser;
    case 'newsgroupaccess'
        web http://www.mathworks.com/pl_newsreader -browser;
    case 'newsletters'
        web http://www.mathworks.com/pl_newsletters -browser;
    case 'studentfaq'
        web http://www.mathworks.com/pl_studentfaq -browser;
    case 'studentcenter'
        web http://www.mathworks.com/pl_studentcenter -browser;
    case 'webstore'
        web http://www.mathworks.com/pl_store -browser;
    case 'checkupdates'
        mainFrame=com.mathworks.mlservices.MatlabDesktopServices.getDesktop.getMainFrame;
        com.mathworks.mde.webintegration.checkforupdates.CheckForUpdatesDialogFactory.getCheckForUpdatesDialog(mainFrame);
end

function result = isJapanese()
    loc = feature( 'locale' );
    result = strncmpi( loc.ctype, 'ja',2 );
end

end

function str = vnvdemodispblock(method,blockh)
% Implements the callbacks for the masks that are
% located on the VnV demos.

% Copyright 2005-2009 The MathWorks, Inc.

str = ' ';
hroot = bdroot(blockh);   
target = [get(hroot,'Path'),'/Highlight'];

dispstrOn = 'Highlight the items \n with requirements \n (double-click)';          
dispstrOff = 'Unhighlight the models \n with requirements \n (double-click)';
dispstrOnOff = 'Highlight/Unhighlight the items \n with requirements \n (double-click)';

if ~strcmp(get_param(hroot,'LibraryType'),'BlockLibrary') 
    switch(method)
        case 'highligther'
            isHighlight=get_param(hroot,'ReqHilite');                            
            if strcmp(isHighlight,'off')                                            
                set_param(hroot,'ReqHilite','on'); 
                set_param(target,'dispstr',dispstrOff);
            else
                set_param(hroot,'ReqHilite','off'); 
                set_param(target,'dispstr',dispstrOn);
            end               
        case 'maskdisplay'                                 
            isHighlight=get_param(hroot,'ReqHilite');
            if strcmp(isHighlight,'off')
                set_param(target,'dispstr',dispstrOn);  
            else
                set_param(target,'dispstr',dispstrOff);
            end       
        case 'report'            
            rmi('report',hroot);
        case 'link'
            rmi_settings_dlg;
        otherwise
            error('SLVNV:vnvdemodispblock:UnknownMethod', 'Unknown method: %s', method);
    end
else
    if strcmp(method,'highligther') | strcmp(method,'maskdisplay')
        if strcmp(get_param(hroot,'Lock'),'on')
            set_param(bdroot(hroot),'Lock','off');
            set_param(target,'dispstr',dispstrOnOff);    
            set_param(bdroot(hroot),'Lock','on');
        else
            set_param(target,'dispstr',dispstrOnOff);    
        end    
    end
end
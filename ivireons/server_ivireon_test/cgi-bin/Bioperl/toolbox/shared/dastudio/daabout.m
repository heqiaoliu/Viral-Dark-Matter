function daabout(product)
%DAABOUT  DAStudio about figure

%   J Breslau
%   Copyright 1995-2009 The MathWorks, Inc.

mlock;

    aboutImageDir = [matlabroot '/toolbox/shared/dastudio/resources/'];
    product = lower(product);
    dy = 0;
    
    switch(product),
    case 'simulink',
        [cdata, map] = imread([aboutImageDir 'about_sl.tif'], 'tif');
        dlgTitle = DAStudio.message('Simulink:dialog:AboutSimulink');

        aboutString = {...
            ver2str(ver('simulink')), ...
        };
    case 'stateflow',
        
        [cdata, map] = imread([aboutImageDir 'about_sf.tif'], 'tif');
        dlgTitle = DAStudio.message('Stateflow:dialog:AboutStateflow');
        dy = 15;
        if sf('License','coder')
            aboutString = {...
                ver2str(ver('stateflow'), true),'',...
                ver2str(ver('coder'), true), ...
            };
        elseif sf('License','basic')
            aboutString = {...
                ver2str(ver('stateflow')), ...
            };
        else
            % No license. Demo version.
            verInfo = regexp(sf('Version'), '^Version\s+(?<Version>\S+)\s+(?<Release>\S+)\s+dated\s+(?<Date>.*)$', 'names');
            verInfo.Name = 'Stateflow';
            aboutString = {...
                ver2str( verInfo, 'Demo'), ...
            };
        end
    otherwise,
        error('DAStudio:UnsupportedProduct', 'Product not supported by DAStudio');
    end

    % if we're already on the screen, bring us forward and return.
    alreadyUp = findall(0, 'tag', tag_l, 'Name', dlgTitle);

    if ~isempty(alreadyUp)
        figure(alreadyUp);
        return;
    end

    dlg = dialog(   'Name',        dlgTitle, ...
                    'Color',       'White', ...
                    'WindowStyle', 'Normal', ...
                    'Visible',     'off', ...
                    'Tag',         tag_l,...
                    'Colormap',    map);
                
    pos = get(dlg, 'position');
    imsize = size(cdata);
    pos(3) = imsize(1);
    pos(4) = imsize(2);
    set(dlg, 'Position', pos);

    ax = axes(      'Parent',   dlg, ...
                    'Visible',  'off', ...
                    'units',    'normal', ...
                    'position', [0 0 1 1], ...
                    'xlim',     [0 imsize(1)], ...
                    'ydir',     'reverse', ...
                    'ylim',     [0 imsize(2)]);

    image('Parent',   ax, 'CData',    cdata);
    text('fontsize',9,'parent',ax, 'string', aboutString, 'horizontala', 'left', 'verticala','middle','pos',[17 125+dy 0]);

    set(dlg, 'Visible', 'on');

end % function


%-------------------
function tag = tag_l
   tag = 'SLSF_About_Dialog';
end % function

%--------------------------------
function str = ver2str(ver, arg2)
    switch nargin
        case 1, 
            name = 'Version';
        case 2,
            switch class(arg2)
                case 'char', 
                    name = [arg2, ' Version'];
                otherwise
                    name = ver.Name; 
            end
        otherwise
            error('DAStudio:UnsupportedArguments', 'bad args');
    end
    
    dateS = datestr(ver.Date,'mmmm dd, yyyy');
    str = [name ' ' ver.Version ' ' ver.Release 10 dateS] ;

end % function

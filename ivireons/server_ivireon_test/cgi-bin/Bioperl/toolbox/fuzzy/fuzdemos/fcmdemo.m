function fcmdemo(action)
%FCMDEMO Fuzzy c-means clustering demo (2-D).
%   FCMDEMO displays a GUI window to let you try out various parameters
%   in fuzzy c-means clustering for 2-D data. You can choose the data set
%   and clustering number from the GUI buttons at right, and then click
%   "Start" to start the fuzzy clustering process.
%
%   Once the clustering is done, you can select one of the clusters by
%   mouse and view the MF surface by clicking the "MF Plot" button.
%   (Note that "MF Plot" is slow because MATLAB is using the command
%   "griddata" to do interpolation among all data points.) To get a
%   better viewing angle, click and drag inside the figure to rotate the
%   MF surface.
%
%   If you choose to use a customized data set, it must be 2-D data.
%   Moreover, the data set is normalized to within the unit cube
%   [0,1] X [0,1] before being clustered.
%
%   File name: fcmdemo.m
%
%   See also DISTFCM, INITFCM, IRISFCM, STEPFCM, FCM.

%   J.-S. Roger Jang, 12-12-94.
%   Copyright 1994-2005 The MathWorks, Inc.
%   $Revision: 1.16.2.6 $  $Date: 2005/12/22 18:10:19 $

global FcmFigH FcmFigTitle FcmAxisH FcmCenter FcmU OldDataID

if nargin == 0,
    action = 'initialize';
end

if strcmp(action, 'initialize'),
    FcmFigTitle = '2-D Fuzzy C-Means Clustering';
    FcmFigH = findobj(0, 'Name', FcmFigTitle);
    if isempty(FcmFigH)
        eval([mfilename, '(''set_gui'')']);
        % ====== change to normalized units
                set(findobj(FcmFigH,'Units','pixels'),'Units','normal');
                % ====== make all UI interruptible
                set(findobj(FcmFigH,'Interrupt','off'),'Interrupt','on');
    else
%	set(FcmFigH, 'color', get(FcmFigH, 'color'));
	refresh(FcmFigH);
    end
elseif strcmp(action, 'set_gui'),   % set figure, axes and gui's
    % ====== setting figure
    
    FcmFigH = figure('Name', FcmFigTitle, 'NumberTitle', 'off','DockControls','off','Resize','off');
    bck_color = get(FcmFigH, 'Color');
    set(FcmFigH,'units','character');
    figPos_ch = get(FcmFigH,'pos');
        
    if figPos_ch(4) < 40
        figPos_ch(4) = 40;
    end

    set(FcmFigH, 'pos', figPos_ch);    
    set(FcmFigH,'units','pixels');
    figPos = get(FcmFigH, 'position');
    figPos(3) = figPos(4) * 1.45;
    set(FcmFigH,'pos',figPos);
    centerfig(FcmFigH);
    
    border = 15;
    axes_pos = [border,border,figPos(4)-2*border,figPos(4)-2*border];
    FcmAxisH = axes('unit', 'pix', 'pos', axes_pos, 'box', 'on', 'Color', [0,0,0]);

    axis([0 1 0 1]);
    axis square;
    set(FcmAxisH, 'xtick', [], 'ytick', []);
    
    txt1_txt = 'Fuzzy c-means (FCM) is a data clustering technique which assigns each data point in the dataset a degree of membership to each cluster.'; 
    mftxt_txt = sprintf('%s\n%s','Select a cluster and', 'click on the button below.');

    sborder = 5;

    uip1_pos = zeros(1,4);
    uip1_pos(1) = axes_pos(3) + 2*border;
    uip1_pos(3) = figPos(3)-(axes_pos(3) + 3*border);
    uip1_pos(4) = round(figPos(4)/figPos_ch(4) * round(3 +  1.5*(length(txt1_txt) / ((figPos_ch(3)/figPos(3)) * uip1_pos(3)) )) ); % inv_ratio *  len_of_line / ratio * width_available
    uip1_pos(2) = figPos(4) - (uip1_pos(4) + border);
    uip1 = uipanel('Parent', FcmFigH, 'units', 'pixels', 'pos', uip1_pos, 'Title', {'About FCM'}, 'FontWeight','bold', 'backgroundColor', bck_color, 'Tag', 'uipanel1');
    
    uip2_pos = zeros(1,4);
    uip2_pos(1) = uip1_pos(1);
    uip2_pos(3) = uip1_pos(3);
    uip2_pos(4) = round(figPos(4)/figPos_ch(4) * 19);
    uip2_pos(2) = figPos(4) - (uip2_pos(4) + uip1_pos(4) + border + sborder);
    uip2 = uipanel('Parent', FcmFigH, 'units', 'pixels', 'pos', uip2_pos, 'Title', {'FCM Settings'}, 'FontWeight','bold', 'backgroundcolor', bck_color, 'Tag', 'uipanel2');
       
    uip3_pos = zeros(1,4);
    uip3_pos(1) = uip1_pos(1);
    uip3_pos(3) = uip1_pos(3);
    uip3_pos(4) = round(figPos(4)/figPos_ch(4) * 8); 
    uip3_pos(2) = figPos(4) - (uip3_pos(4) + uip1_pos(4) + uip2_pos(4) + border + 2*sborder);
    uip3 = uipanel('Parent', FcmFigH, 'units', 'pixels', 'pos', uip3_pos, 'Title', {'Plot Membership Functions'}, 'FontWeight','bold', 'backgroundcolor', bck_color, 'Tag', 'uipanel3');

    set(uip1, 'units', 'character')
    set(uip2, 'units', 'character')
    set(uip3, 'units', 'character')
          
    uip1_posch = get(uip1, 'pos');
    uip2_posch = get(uip2, 'pos');
    uip3_posch = get(uip3, 'pos');
    
    morebut_pos = [uip1_posch(3)-12,0.5,10,1.5];
    txt1_pos = [1.5,morebut_pos(4)+1,uip1_posch(3)-3,uip1_posch(4)-morebut_pos(4)-3];

    morebut = uicontrol('Parent',uip1,'Style','push',...
        'units','character','String','More...','Position',morebut_pos, ...
        'Backgroundcolor', bck_color, 'Tag', 'morebutton', 'HorizontalAlignment', 'center');%, 'ForegroundColor', [0,0,1], 'FontWeight','bold');
    uicontrol('Parent',uip1,'Style','Text','units','character',...
        'String',txt1_txt,'Position',txt1_pos, 'Backgroundcolor', bck_color,...
        'HorizontalAlignment','left','Tag', 'abouttext');


    startbut_pos = [uip2_posch(3)/3,1,uip2_posch(3)/3,1.5];
    
    improvtxt_pos = [1,startbut_pos(2)+startbut_pos(4)+2.5,length('Min. Improvement')+2,1];
    improvedit_pos = [improvtxt_pos(1)+improvtxt_pos(3)+0.1,improvtxt_pos(2)-0.25,uip2_posch(3)-improvtxt_pos(3)-0.1-3,improvtxt_pos(4)+0.5];
    
    itertxt_pos = [1,improvtxt_pos(2)+improvtxt_pos(4)+1,improvtxt_pos(3),1];
    iteredit_pos = [itertxt_pos(1)+itertxt_pos(3)+0.1,itertxt_pos(2)-0.25,uip2_posch(3)-itertxt_pos(3)-0.1-3,itertxt_pos(4)+0.5];

    exptxt_pos = [1,itertxt_pos(2)+itertxt_pos(4)+1,improvtxt_pos(3),1];
    expedit_pos = [exptxt_pos(1)+exptxt_pos(3)+0.1,exptxt_pos(2)-0.25,uip2_posch(3)-exptxt_pos(3)-0.1-3,exptxt_pos(4)+0.5];
    
    clustpmnu_pos = [1,exptxt_pos(2)+exptxt_pos(4)+1,uip2_posch(3)-2.75,1.5];
    clusttxt_pos = [1,clustpmnu_pos(2)+clustpmnu_pos(4),clustpmnu_pos(3),1];
    
    datasetpmnu_pos = [1,clusttxt_pos(2)+clusttxt_pos(4)+1,clustpmnu_pos(3),1.5];
    datasettxt_pos = [1,datasetpmnu_pos(2)+datasetpmnu_pos(4),datasetpmnu_pos(3),1];
    
    datasettxt_txt = 'Choose a sample dataset';
    clusttxt_txt = 'How many clusters do you want?';
    improvtxt_txt = 'Min. Improvement';
    itertxt_txt = 'Max. Iterations';
    exptxt_txt = 'Exponent';
    
    
    
    uicontrol('Parent',uip2,'Style','Text','units','character',...
        'String',datasettxt_txt,'Position',datasettxt_pos, 'Backgroundcolor', bck_color,...
        'HorizontalAlignment','left','Tag', 'datasettxt');
    datasetpmnu = uicontrol('Parent',uip2,'Style','popupmenu','units','character',...
        'Position',datasetpmnu_pos,'string','Data Set 1|Data Set 2|Data Set 3|Data Set 4|Data Set 5|Custom ...',...
        'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Tag', 'data_set');
    uicontrol('Parent',uip2,'Style','text','units','character',...
        'Position',clusttxt_pos, 'string', clusttxt_txt, 'Backgroundcolor', bck_color,...
        'HorizontalAlignment','left','Tag', 'clusttxt');
    clustpmnu = uicontrol('Parent',uip2,'Style','popupmenu','units','character',...
        'Position',clustpmnu_pos, 'string', '2 Clusters|3 Clusters|4 Clusters|5 Clusters|6 Clusters|7 Clusters|8 Clusters|9 Clusters|10 Clusters',...
        'HorizontalAlignment','left','BackgroundColor',[1,1,1],'Tag', 'cluster_menu');
    expedit = uicontrol('Parent',uip2,'Style','edit','units','character',...
        'Position',expedit_pos,'Backgroundcolor', [1,1,1],...
        'HorizontalAlignment','center','Tag', 'datasettxt');
    uicontrol('Parent',uip2,'Style','Text','units','character',...
        'String',exptxt_txt,'Position',exptxt_pos,'Backgroundcolor', bck_color,...
        'HorizontalAlignment','left','Tag', 'datasettxt');
    iteredit = uicontrol('Parent',uip2,'Style','edit','units','character',...
        'Position',iteredit_pos,'Backgroundcolor', [1,1,1],...
        'HorizontalAlignment','center','Tag', 'datasettxt');
    uicontrol('Parent',uip2,'Style','Text','units','character',...
        'String',itertxt_txt,'Position',itertxt_pos,'Backgroundcolor', bck_color,...
        'HorizontalAlignment','left','Tag', 'datasettxt');
    improvedit = uicontrol('Parent',uip2,'Style','edit','units','character',...
        'Position',improvedit_pos,'Backgroundcolor', [1,1,1],...
        'HorizontalAlignment','center','Tag', 'datasettxt');
    uicontrol('Parent',uip2,'Style','Text','units','character',...
        'String',improvtxt_txt,'Position',improvtxt_pos,'Backgroundcolor', bck_color,...
        'HorizontalAlignment','left','Tag', 'datasettxt');
    startbut = uicontrol('Parent',uip2,'Style','pushbutton','units','character',...
        'String', 'START', 'Position',startbut_pos, 'Backgroundcolor', bck_color,...
        'FontWeight', 'bold', 'HorizontalAlignment','left','Tag', 'clustpmnu');


    mfplot_pos = [uip3_posch(3)/3,1,uip3_posch(3)/3,1.5];
    mftext_pos = [2,mfplot_pos(4)+1,uip3_posch(3)-4,uip3_posch(4)-mfplot_pos(4)-3];

    uicontrol('Parent',uip3,'Style','Text','units','character',...
        'String',mftxt_txt,'Position',mftext_pos, 'Backgroundcolor', bck_color,...
        'HorizontalAlignment','center','Tag', 'mftext');
    mfplot = uicontrol('Parent',uip3,'Style','pushbutton',...
        'units','character','String','Plot MF','Position',mfplot_pos, ...
        'Backgroundcolor', bck_color, 'Tag', 'plotbutton');

    % ============ data set
    set(datasetpmnu, 'callback', ...
        [mfilename, '(''get_data''); ', mfilename, '(''init_U''); ', mfilename, '(''label_data0''); ', mfilename, '(''display_data'');']);
    set(datasetpmnu, 'tag', 'data_set');
    % ============ cluster number
    set(clustpmnu, 'callback', [mfilename, '(''cluster_number'');']);
    set(clustpmnu, 'tag', 'cluster_number');
    % ============ clear center
    set(mfplot, 'tag', 'mf_plot');
    set(mfplot, 'callback', [mfilename, '(''mf_plot'')']);
    % ============ start & stop
    set(startbut, 'tag', 'start');
    set(startbut, 'callback', [mfilename, '(''start_stop'')']);
    % ============ exponential
    set(expedit, 'string', '2', 'tag', 'exponent', 'callback', [mfilename, '(''exponent'')']);
    % ============ max iteration
    set(iteredit,'string', '100','tag', 'max_iter');
    % ============ epsilson
    set(improvedit, 'string', '1e-5', 'tag', 'min_impro');
    % ============ info
    set(morebut, 'tag', 'info', 'callback', [mfilename, '(''info'')']);
    
    % creating invisible UI items so that the old code works
    uicontrol('Parent',uip3,'Style','radio','units','character',...
        'Visible','off', 'Position',mftext_pos,...
        'value', 1, 'Tag', 'label_data');
    uicontrol('Parent',uip3,'Style','push','units','character',...
        'Visible','off', 'Position',mftext_pos,...
        'Tag', 'clear_traj');

    % setting initial values for GUI. 
    % ============ initial settings for data set
    OldDataID = 2;
    set(findobj(FcmFigH, 'tag', 'data_set'), 'value', OldDataID);
    % ============ initial settings for cluster number 
    set(findobj(FcmFigH, 'tag', 'cluster_number'), 'value', 2);
    % ============ initial settings for exponent 
    exponent = 2.0;
    set(findobj(FcmFigH, 'tag', 'exponent'), 'string', num2str(exponent));
    % ============ initial settings for max_iter 
    max_iter = 100;
    set(findobj(FcmFigH, 'tag', 'max_iter'), 'string', num2str(max_iter));
    % ============ initial settings for min_impro 
    min_impro = 1e-5;
    set(findobj(FcmFigH, 'tag', 'min_impro'), 'string', num2str(min_impro));
    % ============ GUI initial operations
    eval([mfilename, '(''get_data'')']);
    eval([mfilename, '(''init_U'')']);
    eval([mfilename, '(''label_data0'')']);
    eval([mfilename, '(''display_data'')']);
    eval([mfilename, '(''set_mouse_action'')']);
    % ============ set user data
    uiH = [datasetpmnu, clustpmnu, 0, 0, mfplot, startbut, 0, 0, 0, morebut, 0]; 
    set(FcmFigH, 'userdata', uiH);

elseif strcmp(action, 'start_stop'),
    
    eval([mfilename, '(''clear_traj'')']);
    if ~isempty(findobj(FcmFigH, 'string', 'START')), 
        eval([mfilename, '(''start_clustering'')']);
    else    % stop clustering
        set(findobj(FcmFigH, 'tag', 'start'), 'string', 'START');
    end
elseif strcmp(action, 'start_clustering'),
    % === set some buttons to be uninterruptible
    % The following does not work
    %set(findobj(FcmFigH, 'tag', 'data_set'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'cluster_number'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'clear_traj'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'mf_plot'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'exponent'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'max_iter'), 'interrupt', 'no');
    %set(findobj(FcmFigH, 'tag', 'min_impro'), 'interrupt', 'no');

    set(findobj(FcmFigH, 'tag', 'data_set'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'cluster_number'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'clear_traj'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'mf_plot'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'exponent'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'max_iter'), 'enable', 'off');
    set(findobj(FcmFigH, 'tag', 'min_impro'), 'enable', 'off');
    set(findobj(FcmFigH, 'string', 'Expo.:'), 'enable', 'off');
    set(findobj(FcmFigH, 'string', 'Iterat.:'), 'enable', 'off');
    set(findobj(FcmFigH, 'string', 'Improv.:'), 'enable', 'off');

    % === change label of start
    set(findobj(FcmFigH, 'tag', 'start'), 'string', 'Stop');
    % === delete selectH
    delete(findobj(FcmFigH, 'tag', 'selectH'));
    set(findobj(FcmFigH, 'tag', 'mf_plot'), 'userdata', []);
    % === find some clustering parameters
    expo = str2double(get(findobj(FcmFigH, 'tag', 'exponent'), 'string'));
    cluster_n = get(findobj(FcmFigH, 'tag', 'cluster_number'), 'value')+1;
    max_iter = str2double(get(findobj( ...
        FcmFigH, 'tag', 'max_iter'), 'string'));
    min_eps = str2double(get(findobj( ...
        FcmFigH, 'tag', 'min_impro'), 'string'));
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    data = get(dataplotH, 'userdata');
    data_n = size(data, 1);
    % === initial partition
    FcmU = initfcm(cluster_n, data_n);
    % === find initial centers
    [FcmU, FcmCenter] = stepfcm(data, FcmU, cluster_n, expo);
    center_prev = FcmCenter;
    U_prev = FcmU;
    % === Graphic handles for traj and head 
    headH = line(ones(2,1)*FcmCenter(:,1)', ones(2,1)*FcmCenter(:,2)',...
        'erase', 'none', 'LineStyle', 'none', 'Marker', '.', ...
        'markersize', 30, 'tag', 'headH');
    trajH = line(zeros(2,cluster_n), zeros(2,cluster_n), ...
        'erase', 'none', 'linewidth', 3, ...
        'tag', 'trajH');
    % === array for objective function 
    err = zeros(max_iter, 1);

    for i = 1:max_iter,
        [FcmU, FcmCenter, err(i)] = stepfcm( ...
            data, U_prev, cluster_n, expo);
        %fprintf('Iteration count = %d, obj. fcn = %f\n', i, err(i));
        % === label each data if necessary
        eval([mfilename, '(''label_data'')']);
        % === check ternimation invoked from GUI
        if findobj(FcmFigH, 'string', 'START')
            break;
        end
        tempusdt=get(findobj(FcmFigH, 'string', 'Close'), 'userdata');
        if ~isempty(tempusdt)&(tempusdt == 1),
            break;
        end
        % === check normal termination condition
        if i > 1,
            if abs(err(i) - err(i-1)) < min_eps, break; end,
        end
%       if max(max(U_prev - FcmU)) < min_eps, break; end,
        % === refresh centers for animation
        for j = 1:cluster_n,
            set(headH(j), 'xdata', FcmCenter(j, 1), 'ydata', FcmCenter(j, 2));
            set(trajH(j), 'xdata', [center_prev(j, 1) FcmCenter(j, 1)], ...
            'ydata', [center_prev(j, 2) FcmCenter(j, 2)]);
        end
        drawnow;
        center_prev = FcmCenter;
        U_prev = FcmU;
    end
    % === change the button label
    tempusdt=get(findobj(FcmFigH, 'string', 'Close'), 'userdata');
    if  ~isempty(tempusdt)&tempusdt== 1,
        delete(FcmFigH);
    else
        % change to 'Start'
        set(findobj(FcmFigH, 'tag', 'start'), 'string', 'START');
        % make everything interruptible
                %set(findobj(FcmFigH,'Interrupt','no'),'Interrupt','yes');
                set(findobj(FcmFigH,'enable','off'),'enable','on');
    end
elseif strcmp(action, 'label_data0'),   % initialize labelH
    cluster_n = get(findobj(FcmFigH, 'tag', 'cluster_number'), 'value')+1;
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    data = get(dataplotH, 'userdata');
    data_n = size(data, 1);
    label_data = get(findobj(FcmFigH, 'tag', 'label_data'), 'value');

    maxU = max(FcmU);
    x=[];
    y=[];
    for i = 1:cluster_n,
        index = find(FcmU(i, :) == maxU);
        cluster = data(index', :);
        if isempty(cluster), cluster = [nan nan]; end
        x = fstrvcat(x, cluster(:, 1)');
        y = fstrvcat(y, cluster(:, 2)');
    end
    x(find(x==0)) = nan*find(x==0); % get rid of padded zeros
    y(find(y==0)) = nan*find(y==0); % get rid of padded zeros
    
    labelH = line(x', y', 'LineStyle', 'none', 'Marker', 'o', 'visible', 'off');
    set(labelH, 'erase', 'none');
    set(findobj(FcmFigH, 'tag', 'label_data'), 'userdata', labelH); 
elseif strcmp(action, 'label_data'),
    cluster_n = get(findobj(FcmFigH, 'tag', 'cluster_number'), 'value')+1;
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    data = get(dataplotH, 'userdata');
    labelH = get(findobj(FcmFigH, 'tag', 'label_data'), 'userdata');
    label_data = get(findobj(FcmFigH, 'tag', 'label_data'), 'value');
    if label_data ~= 0,
        set(dataplotH, 'visible', 'off');
        maxU = max(FcmU);
        for i = 1:cluster_n,
            index = find(FcmU(i, :) == maxU);
            cluster = data(index', :);
            if isempty(cluster), cluster = [nan nan]; end
            set(labelH(i), 'xdata', cluster(:, 1), ...
                'ydata', cluster(:, 2));
        end
        set(labelH, 'visible', 'on');
    else
        set(dataplotH, 'visible', 'on');
        set(labelH, 'visible', 'off');
    end
elseif strcmp(action, 'get_data'),
    getDataH = findobj(FcmFigH, 'tag', 'data_set');
    dataID = get(getDataH, 'value'); 
    no_change = 0;
    if dataID == 1,
        data_n = 400;
        data = rand(data_n, 2);
        % === cluster 1
        dist1 = distfcm([0.2 0.2], data);
        index1 = (dist1 < 0.15)';
        % === cluster 2
        dist2 = distfcm([0.7 0.7], data);
        index2 = (dist2 < 0.25)';
        % === cluster 3
        index3 = data(:,1) - data(:, 2) - 0.1 < 0;
        index4 = data(:,1) - data(:, 2) + 0.1 > 0;
        index5 = data(:,1) + data(:, 2) - 0.4 > 0;
        index6 = data(:,1) + data(:, 2) - 1.4 < 0;
        % === final data
        data(find((index1|index2|(index3&index4&index5&index6)) ...
            == 0), :) = [];
    elseif dataID == 2,
        data_n = 100;
        % === cluster 1
        c1 = [0.6 0.2]; radius1 = 0.2;
        data1 = randn(data_n, 2)/10 + ones(data_n, 1)*c1;
        % === cluster 2
        c2 = [0.2 0.6]; radius2 = 0.2;
        data2 = randn(data_n, 2)/10 + ones(data_n, 1)*c2;
        % === cluster 3
        c3 = [0.8 0.8]; radius3 = 0.2;
        data3 = randn(data_n, 2)/10 + ones(data_n, 1)*c3;
        % === final data
        data = [data1; data2; data3];
        index = (min(data')>0) & (max(data')<1);
        data(find(index == 0), :) = [];
    elseif dataID == 3,
        data_n = 100;
        k = 10;
        c1 = [0.125 0.25];
        data1 = randn(data_n, 2)/k + ones(data_n, 1)*c1;
        c2 = [0.625 0.25];
        data2 = randn(data_n, 2)/k + ones(data_n, 1)*c2;
        c3 = [0.375 0.75];
        data3 = randn(data_n, 2)/k + ones(data_n, 1)*c3;
        c4 = [0.875 0.75];
        data4 = randn(data_n, 2)/k + ones(data_n, 1)*c4;
        data = [data1; data2; data3; data4];
        index = (min(data')>0) & (max(data')<1);
        data(find(index == 0), :) = [];
    elseif dataID == 4,
        data_n = 100;
        % === cluster 1
        c1 = [0.2 0.2];
        data1 = randn(data_n, 2)/15 + ones(data_n, 1)*c1;
        % === cluster 2
        c2 = [0.2 0.5];
        data2 = randn(data_n, 2)/15 + ones(data_n, 1)*c2;
        % === cluster 3
        c2 = [0.2 0.8];
        data3 = randn(data_n, 2)/15 + ones(data_n, 1)*c2;
        % === cluster 4
        c3 = [0.8 0.5];
        data4 = randn(data_n, 2)/10 + ones(data_n, 1)*c3;
        % === final data
        data = [data1; data2; data3; data4];
        index = (min(data')>0) & (max(data')<1);
        data(find(index == 0), :) = [];
    elseif dataID == 5,
        data_n = 300;
        data = rand(data_n, 2);
    elseif dataID == 6, % Customized data set
        data_file = uigetfile('*.dat');
        if data_file==0, %data_file == 0 | data_file == '',    % cancelled
            no_change = 1;
        else        % loading data
            eval([mfilename, '(''clear_traj'')']);
            eval(['load ' data_file]);
            tmp = find(data_file=='.');
            if tmp == [],   % data file has no extension.
                eval(['data=' data_file ';']);
            else
                eval(['data=' data_file(1:tmp-1) ';']);
            end
            if size(data, 2) ~= 2,
                fprintf('Given data is not 2-D!\n');
                no_change = 1;
            end
        end
    else
        error('Selected data not found!');
    end
    if no_change,
        set(getDataH, 'value', OldDataID); 
    else        
        % normalize data set
        maxx = max(data(:,1)); minx = min(data(:,1));
        data(:,1) = (data(:,1)-minx)/(maxx-minx); 
        maxy = max(data(:,2)); miny = min(data(:,2));
        data(:,2) = (data(:,2)-miny)/(maxy-miny); 
        % process data
        OldDataID = dataID; 
        delete(get(FcmAxisH, 'child'));
%        set(FcmFigH, 'color', get(FcmFigH, 'color'));
	refresh(FcmFigH);
        dataplotH = line(data(:, 1), data(:, 2), 'color', 'g', ...
            'LineStyle', 'none', 'Marker', 'o', 'visible', 'off', ...
            'clipping', 'off');
        set(dataplotH, 'userdata', data);
        set(getDataH, 'userdata', dataplotH);
    end
elseif strcmp(action, 'init_U'),
    cluster_n = get(findobj(FcmFigH, 'tag', 'cluster_number'), ...
        'value')+1;
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    data = get(dataplotH, 'userdata');
    data_n = size(data, 1);
    FcmU = initfcm(cluster_n, data_n);
elseif strcmp(action, 'display_data'),
    label_data = get(findobj(FcmFigH, 'tag', 'label_data'), 'value');
    dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
    labelH = get(findobj(FcmFigH, 'tag', 'label_data'), 'userdata');
    if label_data == 0,
        set(dataplotH, 'visible', 'on');
        set(labelH, 'visible', 'off');
    else
        set(dataplotH, 'visible', 'off');
        set(labelH, 'visible', 'on');
    end
elseif strcmp(action, 'cluster_number'),
    eval([mfilename, '(''init_U'')']);
    delete(get(findobj(FcmFigH, 'tag', 'label_data'), 'userdata'));
    delete(findobj(FcmFigH, 'tag', 'headH'));
    delete(findobj(FcmFigH, 'tag', 'trajH'));
    delete(findobj(FcmFigH, 'tag', 'selectH'));
    FcmCenter = [];
    set(findobj(FcmFigH, 'tag', 'mf_plot'), 'userdata', []);
    eval([mfilename, '(''label_data0'')']);
    eval([mfilename, '(''display_data'')']);
elseif strcmp(action, 'clear_traj'),
    if ~isempty(findobj(FcmFigH, 'string', 'START')),
%	set(FcmFigH, 'color', get(FcmFigH, 'color'));
	refresh(FcmFigH);
        delete(findobj(FcmFigH, 'tag', 'trajH'));
    end
elseif strcmp(action, 'clear_all'),
    if ~isempty(findobj(FcmFigH, 'string', 'START')),
%	set(FcmFigH, 'color', get(FcmFigH, 'color'));
	refresh(FcmFigH);
        delete(findobj(FcmFigH, 'tag', 'headH'));
    end
elseif strcmp(action, 'close'),
    set(findobj(FcmFigH, 'string', 'Close'), 'userdata', 1);
    if ~isempty(findobj(FcmFigH, 'string', 'START')),
        delete(FcmFigH);
    end
elseif strcmp(action, 'mf_plot'),
    old_pointer = get(FcmFigH, 'pointer');
    set(FcmFigH, 'pointer', 'watch');
    % looping till mouse action is done
    which_cluster = get(findobj(FcmFigH, 'tag', 'mf_plot'), 'userdata');
    if isempty(which_cluster),
        fprintf('Use mouse to select a cluster first.\n');
    else
        title = ['MF Plot for Cluster ', int2str(which_cluster)];
        MfFigH = findobj(0, 'Name', title);
        if isempty(MfFigH), % create a new MF plot
            dataplotH = get(findobj(FcmFigH, 'tag', 'data_set'), 'userdata');
            data = get(dataplotH, 'userdata');
            tmp = FcmU';
            % use griddata to do surface plot
            fprintf('Using "griddata" to plot MF surface ...\n');
            [XI, YI] = meshgrid(0:0.1:1, 0:0.1:1);
            ZI = griddata(data(:,1), data(:, 2), tmp(:, which_cluster), XI, YI);
            % Create a new figure window
            pos = get(0, 'defaultfigurepos');
            pos(3) = pos(3)*0.75; pos(4) = pos(4)*0.75;
            MfFigH = figure('Name', title, ...
                'NumberTitle', 'off', 'position', pos, 'DockControls','off');
	    % V4 color default
	    colordef(MfFigH, 'black');
            mesh(XI, YI, ZI);
            xlabel('X'), ylabel('Y'), zlabel('MF');
            axis([0 1 0 1 0 1]); set(gca, 'box', 'on');
            rotate3d on;
            set(MfFigH, 'HandleVisibility', 'callback');
        end
        set(0, 'Currentfigure', MfFigH);
    end
    set(FcmFigH, 'pointer', old_pointer);
elseif strcmp(action, 'set_mouse_action'),
    % action when button is first pushed down
    action1 = [mfilename '(''mouse_action1'')'];
    % actions after the mouse is pushed down
    action2 = ' ';
    % action when button is released
    action3 = ' ';

    % temporary storage for the recall in the down_action
    set(gca,'UserData',action2);

    % set action when the mouse is pushed down
    down_action=[ ...
        'set(gcf,''WindowButtonMotionFcn'',get(gca,''UserData''));' ...
        action1];
    set(gcf,'WindowButtonDownFcn',down_action);

    % set action when the mouse is released
    up_action=[ ...
        'set(gcf,''WindowButtonMotionFcn'','' '');', action3];
    set(gcf,'WindowButtonUpFcn',up_action);
elseif strcmp(action, 'mouse_action1'),
    curr_info = get(gca, 'CurrentPoint');
    CurrPt = [curr_info(1, 1) curr_info(1,2)];
    if ~isempty(FcmCenter),
        [junk, which_cluster] = min(distfcm(CurrPt, FcmCenter));
        set(findobj(gcf, 'tag', 'mf_plot'), 'userdata', which_cluster);
        delete(findobj(gcf, 'tag', 'selectH'));
        selectH = line(FcmCenter(which_cluster, 1), FcmCenter(which_cluster, 2), ...
            'tag', 'selectH', 'LineStyle', 'none', 'Marker', 'o', 'markersize', 30);
    end
elseif strcmp(action, 'exponent'),
    expo = str2double(get(findobj(FcmFigH, 'tag', 'exponent'), 'string'));
    if expo <= 1,
        fprintf('The exponent for MF''s should be greater than 1!\n');
        set(findobj(FcmFigH, 'tag', 'exponent'), 'string', num2str(1.01));
    end
elseif strcmp(action, 'info'),
    helpview([matlabroot '\toolbox\fuzzy\fuzdemos\html\fcmdemo_codepad.html'])
%   title = '2-D Fuzzy C-means Clustering';
%   help_string = ...        
%   [' You are seeing fuzzy C-means clustering         '  
%    ' when the data sets are 2-dimensional. You can   '  
%    ' choose the data set and clustering number from  '  
%    ' the GUI buttons at right, and then click        '  
%    ' "Start" to start the fuzzy clustering process.  '  
%    '                                                 '  
%    ' Once the clustering is done, you can select     '  
%    ' one of the clusters by mouse and view the MF    '  
%    ' surface by clicking the "MF Plot" button.       '  
%    '                                                 '  
%    ' If you choose to use a customized data set,     '  
%    ' it must be 2-D data. Moreover, the data set     '  
%    ' is normalized to within the unit cube           '  
%    ' [0,1] X [0,1] before being clustered.           '  
%    '                                                 '  
%    ' File name: fcmdemo.m                            '];
%   fhelpfun(title, help_string);
else
    fprintf('Given string is "%s".\n', action);
    error('Unrecognized action string!');
end

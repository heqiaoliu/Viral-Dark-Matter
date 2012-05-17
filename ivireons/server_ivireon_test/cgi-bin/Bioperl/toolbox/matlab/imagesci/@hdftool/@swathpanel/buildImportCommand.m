function cmd = buildImportCommand(this, bImport)
%BUILDIMPORTCOMMAND Create the command that will be used to import the data.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   BIMPORT: This indicates if the string will be used for import.
%       If this is the case, we will do some extra error checking.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/01/19 02:55:46 $

    infoStruct = this.currentNode.nodeinfostruct;
    selBtn = this.subsetSelectionApi.getSelected();
    varName = get(this.filetree,'wsvarname');
    currentNode = this.currentNode;

    fileName = this.filetree.filename;
    swathName = this.currentNode.displayname;
    baseCmd = [varName ' = hdfread(''' fileName ''', ''' swathName ''', ''Fields'', ''%s''%s);'];
    baseCmd = strrep(baseCmd, '\', '\\');
    errorStr = '';

    switch (selBtn)
        case xlate('No Subsetting')
            cmd = buildNoSubsettingCmd(baseCmd);
        case xlate('Direct Index')
            cmd = buildDirectIndexCmd(baseCmd, this.subsetApi{2});
        case xlate('Geographic Box')
            cmd = buildGeographicBoxCmd(baseCmd, this.subsetApi{3});
        case xlate('Time')
            cmd = buildTimeCmd(baseCmd, this.subsetApi{4});
        case xlate('User-defined')
            cmd = buildUserDefinedCmd(baseCmd, this.subsetApi{5});
        otherwise
            cmd = '';
    end

    set(this.filetree,'matlabCmd',cmd);

    %=======================================================
    function outCmd = buildNoSubsettingCmd(baseCmd)
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,'');
    end
    %=======================================================
    function outCmd = buildDirectIndexCmd(baseCmd, h)
        data = h.getTableData();
        str = sprintf(',''Index'',{[%s],[%s],[%s]}',...
            num2str([data{:,1}]), ...
            num2str([data{:,2}]), ...
            num2str([data{:,3}]) );
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            str);
    end
    %=======================================================
    function outCmd = buildGeographicBoxCmd(baseCmd, h)
        outCmd       = '';
        boxVals      = h.getBoxCornerValues();
        timeVals     = h.getTime();
        userdefVals  = h.getUserDefined();
        inclMode     = h.getCTInclusionMode();
        geoMode      = h.getGeolocationMode();
        userdefParam = buildUserDefParam(userdefVals);
        timeParam    = buildTimeParam(timeVals, inclMode);
        boxParam     = buildBoxParam('Box',boxVals,inclMode);
        % errorStr is initialized to empty and is only populated if
        % an error occurs in the build-Param nested functions.
        if ~isempty(errorStr)
            errordlg(errorStr,'Invalid subset selection parameter');
            return;
        end
        extParam = sprintf(',''ExtMode'',''%s''',geoMode);
        str = [boxParam,extParam,userdefParam,timeParam];
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            str);
    end
    %=======================================================
    function outCmd = buildTimeCmd(baseCmd, h)
        outCmd = '';
        errorStr     = '';
        timeVals     = h.getTime();
        userdefVals  = h.getUserDefined();
        inclMode     = h.getCTInclusionMode();
        geoMode      = h.getGeolocationMode();
        timeParam    = buildTimeParam(timeVals, inclMode);
        userdefParam = buildUserDefParam(userdefVals);
        if ~isempty(errorStr)
            errordlg(errorStr,'Invalid subset selection parameter');
            return;
        end
        if isempty(timeParam)
            errordlg('Time values must be numbers.','Invalid subset selection parameter');
            return
        end
        extParam = sprintf(',''ExtMode'',''%s''',geoMode);
        str = [timeParam,extParam,userdefParam];
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            str);
    end
    %=======================================================
    function outCmd = buildUserDefinedCmd(baseCmd, h)
        outCmd = '';
        errorStr     = '';
        userdefVals  = h.getUserDefined();
        geoMode      = h.getGeolocationMode();
        userdefParam = buildUserDefParam(userdefVals);
        if ~isempty(errorStr)
            errordlg(errorStr,'Invalid subset selection parameter');
            return;
        end
        extParam = sprintf(',''ExtMode'',''%s''',geoMode);
        str = [userdefParam,extParam];
        outCmd = sprintf(baseCmd,...
            infoStruct.Name,...
            str);
    end
    %======================================================
    function userdefParam = buildUserDefParam(userdefVals)
        userdefParam = '';
        if size(userdefVals,2)<3
            return
        end
        tmp = userdefVals(:,2:3)';
        vals = sprintf('%s ',tmp{:});
        vals = str2num(vals);
        if ~isempty(vals)
            if bImport && mod(length(vals),2)
                % if both min and max values are entered
                errorStr = ['Fill out min and max values for user-',...
                    'defined subsetting methods'];
                return
            else
                len = length(vals)/2;
                for m = 1:len
                    userdefParam = ...
                        sprintf([userdefParam,',''Vertical'',{''%s'',[%s]}'],...
                        userdefVals{m,1},...
                        num2str(vals(m*2-1:m*2)));
                end
            end
        end
    end
    %=====================================================
    function timeParam = buildTimeParam(timeVals, inclMode)
        timeParam = '';
        timeLen = length(find(isnan(timeVals)));
        if timeLen < 2
            % if either start and stop values are entered
            if bImport && timeLen ~= 0
                % if both are not entered.  i.e. start or stop is NaN
                errorStr = 'Enter both start and stop times or neither.';
            else
                timeParam = sprintf(',''Time'',{%s,%s,''%s''}',...
                    num2str(timeVals(1)),...
                    num2str(timeVals(2)),...
                    inclMode);
            end
        end
    end
    %=====================================================
    function boxParam = buildBoxParam(type, boxVals, inclMode)
        if any(isnan(boxVals(:)),1)
            errorStr = 'Latitude and Longitude values must be entered.';
        end
        boxParam = sprintf(',''%s'',{[%s], [%s],''%s''}',...
            type,...
            num2str(boxVals(:,1)'),...
            num2str(boxVals(:,2)'),...
            inclMode);
    end
end


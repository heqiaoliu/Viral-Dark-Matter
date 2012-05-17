classdef InfoPanelMgr < handle
    %InfoPanelMgr Construct an information panel manager object
    %
    %   Warning: This undocumented function may be removed in a future release.

    % Copyright 2008 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:14:38 $

    %===========================================================================
    % Public properties
    properties
        PanelContentIndices     % Vector of indices that determine the contents
                                % of the panel.
    end

    %===========================================================================
    % Protected properties
    properties (Access = protected)
        ContentsList                % Full list of panel contents
        DefaultPanelContentIndices  % Default indices
    end

    %===========================================================================
    % Protected abstract methods
    methods (Abstract, Access = protected)
        createList(this)
    end

    %===========================================================================
    % Public abstract methods
    methods (Abstract)
        prepareTableData(this, hEye)
    end

    %===========================================================================
    % Public methods
    methods
        function names = getScreenNames(this)
            contents = this.ContentsList;
            [names{1:length(contents)}]=deal(contents.ScreenName);
        end
        %-----------------------------------------------------------------------
        function names = getFieldNames(this)
            contents = this.ContentsList;
            [names{1:length(contents)}]=deal(contents.FieldName);
        end
        %-----------------------------------------------------------------------
        function quickHelp = getQuickHelp(this)
            contents = this.ContentsList;
            [quickHelp{1:length(contents)}]=deal(contents.QuickHelp);
        end
        %-----------------------------------------------------------------------
        function reset(this)
            this.PanelContentIndices = this.DefaultPanelContentIndices;
        end
    end

    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function itemValue = getItemValue(this, hEye, item)
            %GETITEMVALUE Return the property value
            %   OUT = GETITEMVALUE(THIS, HEYE, ITEM) return OUT, which is the
            %   value of the ITEM property of the eye diagram object HEYE

            if isempty(hEye)
                itemValue = '-';
            else
                dotLocation = findstr('.', item.FieldName);
                if isempty(dotLocation)
                    itemValue = get(hEye, item.FieldName);
                else
                    fName = item.FieldName;
                    itemValue = get(...
                        get(hEye, fName(1:dotLocation-1)),...
                        fName(dotLocation+1:end));
                end
            end
        end
        %-----------------------------------------------------------------------
        function [formattedValue units] = ...
                formatItemValue(this, value, fracDigits, itemUnit, outStyle)
            %FORMATITEMVALUE Format the value using engineering units
            %   Formats the value using engineering units and FRACDIGITS
            %   fractional digits. ITEMUNIT is used to determine if we should
            %   not use engunits (e.g. %). OUTSTYLE can be s (character) or f
            %   (number). Returns FORMATTEDVALUE and UNITS, which is the
            %   engineering unit prefix.
            
            if nargin == 4
                outStyle = 's';
            end

            if ischar(value)
                % If char then do not format
                formattedValue = {value};
                units = '';
            elseif isnan(value)
                % NaN
                if outStyle == 'f'
                    formattedValue = value;
                else
                    formattedValue = repmat({'-'}, size(value));
                end
                units = '';
            else
                if isempty(itemUnit) || strncmp(itemUnit, '%', 1)
                    y = value;
                    units = '';
                else
                    [y e units] = engunits(value);
                    % Make sure the significant digits are used properly.
                    % enguints returns 999.9999999 and m for input
                    % 0.99999999999.  SInce fracDigit controls significant
                    % digits, we should round this, e.g. if fracDigit is 3, then
                    % this should be 1 and no engineeing units.
                    if round(abs(y)+10^(-fracDigits)) == 1000
                        olde = e;
                        [y e units] = engunits(value*olde);
                        y = y / olde;
                    end
                end

                basicFormat = ['%1.' num2str(fracDigits) 'g'];

                [M N] = size(value);
                if N >1
                    % If more than one value, then use [val1 val2 ...] format
                    formatStr = ['[' repmat([basicFormat ' '], 1, N)];
                    formatStr(end) = ']';
                else
                    formatStr = basicFormat;
                end

                formattedValue = cell(M,1);
                for p=1:M
                    itemValue = sprintf(formatStr, y(p, :));
                    itemValue = regexprep(itemValue, 'e-0*', 'e-');
                    itemValue = regexprep(itemValue, 'e\+0*', 'e');
                    formattedValue{p} = itemValue;
                end
                
                if outStyle == 'f'
                    % For double format output, convert the cell array of string
                    % to double.
                    temp = zeros(M,N);
                    for p=1:size(formattedValue, 1)
                        temp(p,:) = str2num(formattedValue{p,:}); %#ok<ST2NM>
                    end
                    formattedValue = temp;
                end
            end
        end
    end
end
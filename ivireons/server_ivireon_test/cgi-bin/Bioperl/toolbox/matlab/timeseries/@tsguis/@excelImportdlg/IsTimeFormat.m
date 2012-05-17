function [flag, Value, answer]=IsTimeFormat(h,numberFormat,rawData,cellstr,choice)
% ISTIMEFORMAT check time format of a single cell

% input parameters should be in Cell Array format
% output:   between 0~31: standard MATLAB supported date/time format
%           -1: double values
%           NaN: string or other cases

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.


% get value from cell
numberFormat=cell2mat(numberFormat);
rawData=cell2mat(rawData);
Value=rawData;
answer='';
% check if date/time format
if isnumeric(rawData) && ~isnan(rawData)
    % it can be a double or a time format
    if ~isempty(strfind(numberFormat,':'))
        % a time format identified
        % get matlab corresponding format number if there is a match
        if strcmp(numberFormat,'h:mm:ss') || strcmp(numberFormat,'h:mm:ss;@') || ...
           strcmp(numberFormat,'[$-409]h:mm:ss') || strcmp(numberFormat,'[$-409]h:mm:ss;@') || ...
           strcmp(numberFormat,'[$-F400]h:mm:ss') || strcmp(numberFormat,'[$-F400]h:mm:ss;@')
            answer = 'HH:MM:SS';
            flag=13;
            return
        elseif strcmp(numberFormat,'h:mm:ss AM/PM') || strcmp(numberFormat,'h:mm:ss AM/PM;@') || ...
               strcmp(numberFormat,'[$-409]h:mm:ss AM/PM') || strcmp(numberFormat,'[$-409]h:mm:ss AM/PM;@') || ...
               strcmp(numberFormat,'[$-F400]h:mm:ss AM/PM') || strcmp(numberFormat,'[$-F400]h:mm:ss AM/PM;@')
            answer = 'HH:MM:SS PM';
            flag=14;
            return
        elseif strcmp(numberFormat,'h:mm') || strcmp(numberFormat,'h:mm;@') || ...
               strcmp(numberFormat,'[$-409]h:mm') || strcmp(numberFormat,'[$-409]h:mm;@') || ...
               strcmp(numberFormat,'[$-F400]h:mm') || strcmp(numberFormat,'[$-F400]h:mm;@')
            answer = 'HH:MM';
            flag=15;
            return
        elseif strcmp(numberFormat,'h:mm AM/PM') || strcmp(numberFormat,'h:mm AM/PM;@') || ...
               strcmp(numberFormat,'[$-409]h:mm AM/PM') || strcmp(numberFormat,'[$-409]h:mm AM/PM;@') || ...
               strcmp(numberFormat,'[$-F400]h:mm AM/PM') || strcmp(numberFormat,'[$-F400]h:mm AM/PM;@')
            answer = 'HH:MM PM';
            flag=16;            
            return
        else
            % for other cases, use the default matlab time format 13 
            answer = 'HH:MM:SS';
            flag=13;
            return
        end
    else
        % not an absolute date/time format
        flag=-1;
        return
    end
end
if ischar(rawData)
    % it can be any string or a date format
%     if ~isfield(h.Handles,'COMBdataSample')
        try 
            Value=datenum(rawData);
        catch
            % not an absolute date/time format
            if strcmp(choice,'col')
                prompt={sprintf('Please specify a custom format for Column ''%s'', e.g. dd.mm.yyyy',cellstr)};
            else
                prompt={sprintf('Please specify a custom format for Row ''%s'', e.g. dd.mm.yyyy',cellstr)};
            end
            name='Input for date format';
            numlines=1;
            while true
                answer=inputdlg(prompt,name,numlines);
                if ~isempty(answer)
                    answer=answer{:};
                    if ~isempty(answer)
                        try 
                            Value=datenum(rawData,answer);
                        catch
                            continue
                        end
                        flag=inf;
                    else
                        answer='cancel';
                        flag=NaN;
                    end
                else
                    answer='cancel';
                    flag=NaN;
                end
                return                
            end
        end
%     else
%         if get(h.Handles.COMBdataSample,'Value')==1
%             % time vector is a column
%             try 
%                 Value=datenum(rawData,h.IOData.formatcell.columnIsAbsTime);
%             catch
%                 % not an absolute date/time format
%                 flag=NaN;
%                 return
%             end
%         else
%             % time vector is a row
%             try 
%                 Value=datenum(rawData,h.IOData.formatcell.rowIsAbsTime);
%             catch
%                 % not an absolute date/time format
%                 flag=NaN;
%                 return
%             end
%         end        
%     end
    % it is a date format
    if Value==floor(Value)
        % only in date format
        % use default matlab display 22
        flag=1;
        return
    else
        % date+time format
        % use default matlab display 22
        flag=0;
        return
    end
end
% FOR OTHER CASES
flag=NaN;

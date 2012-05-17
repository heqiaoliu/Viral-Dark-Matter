function setArray(this,ArrayValue)
%SETARRAY  Writes array value.
%
%   SETARRAY(VirtualArray,ArrayValue)

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/08/20 22:59:27 $

% Update the metadata to reflect the new value
if ~ishandle(this.MetaData)
    error('timeseriesSrcArray:setArray:noMetaData',...
        'Metadata property is empty. A meta data object must be assigned to this property before it can be read.')
end

% Many data sinks may store time vectors as datestrs. To support being
% able to write times in this form, if the @timemetadata format is a
% datestr, the variable is "time" and the time vecotor is defined in an
% absolute sense then the time vecotr will be written to the data src
% as an array of datestrs
if strcmp(this.Variable.Name,'Time') && strcmp(this.Metadata.Format,'datestr') && ...
    ~isempty(this.Metadata.Startdate)
    ArrayValueCell = cellstr(datestr(ArrayValue*tsunitconv('days',this.Metadata.Units)+ ...
        datenum(this.Metadata.Startdate)));
    % Store array
    this.Storage.setArray(ArrayValueCell,this.Variable);
else
    % Store array
    this.Storage.setArray(ArrayValue,this.Variable);
end

% Update the metadata to reflect the new value
this.MetaData.setData(ArrayValue);




function update(this)
%UPDATE   Update the text with the new data.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:42:52 $

source = this.Application.DataSource;
if isempty(source)
    return;
end

newData = this.DataObject;

newData.FrameData = getRawData(source, 1);

if isa(newData, 'scopeextensions.TextData')
    process(newData);
    newText = toText(newData);
else
    newText = 'Cannot read information from the current source.';
end

set(this.InfoText, 'string', newText);

% [EOF]

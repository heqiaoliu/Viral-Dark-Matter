function update(this,~)
%UPDATE Update VideoInfo object to react to a new movie (source data object)

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2010/03/31 18:43:12 $

source = this.hAppInst.DataSource;
video  = this.hAppInst.Visual;
if isempty(source)
    return;
end

% Need to reset these properties in response to a new data source:
this.SourceType = source.Type;
maxDimensions   = getMaxDimensions(source, 1);
this.ImageSize  = sprintf('%d H x %d W', maxDimensions(1), maxDimensions(2));
sourceNameChanged(this, false);

if video.isIntensity
    s = 'Intensity';
else
    s = 'RGB';
end

this.ColorSpace = s;  % rgb, intensity
this.DataType   = getDataTypes(source, 1);

% Update the keyboard help datasource-specific entries:
%
this.PlaybackInfo = getDataInfo(source.Controls);
this.TitlePrefix  = getTitleString(this);

% [EOF]

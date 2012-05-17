function dlgOrTabStruct = fimathdialog(h, name,isTab)

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.8 $

if nargin == 2 || isempty(isTab)
  isTab = false;
end

%-----------------------------------------------------------------------
% First Row contains:
% - RoundMode label widget
% - RoundMode combobox widget
%----------------------------------------------------------------------- 
RoundModeLbl.Name = 'Round mode:';
RoundModeLbl.Type = 'text';
RoundModeLbl.RowSpan = [1 1];
RoundModeLbl.ColSpan = [1 1];
RoundModeLbl.Tag = 'RoundModeLbl';

RoundMode.Name = '';
RoundMode.RowSpan = [1 1];
RoundMode.ColSpan = [2 2];
RoundMode.Tag = 'RoundMode';
RoundMode.Type = 'combobox';
% Convert the first character in each string of
% the round modes to upper case
rmodes = set(h, 'RoundMode')';
charRModes = char(rmodes);
charRModes(1:length(rmodes)) = upper(charRModes(1:length(rmodes)));
rmodes = cellstr(charRModes);
RoundMode.Entries = rmodes';
RoundMode.ObjectProperty = 'RoundMode';
RoundMode.Mode = 1;
RoundMode.DialogRefresh = 1;

%-----------------------------------------------------------------------
% Second Row contains:
% - OverflowMode label widget
% - OverflowMOde combobox widget
%----------------------------------------------------------------------- 
OverflowModeLbl.Name = 'Overflow mode:';
OverflowModeLbl.Type = 'text';
OverflowModeLbl.RowSpan = [2 2];
OverflowModeLbl.ColSpan = [1 1];
OverflowModeLbl.Tag = 'OverflowModeLbl';

OverflowMode.Name = '';
OverflowMode.RowSpan = [2 2];
OverflowMode.ColSpan = [2 2];
OverflowMode.Tag = 'OverflowMode';
OverflowMode.Type = 'combobox';
% Convert the first character in each string of
% the overflow modes to upper case
ofmodes = set(h,'OverflowMode')';
charOfModes = char(ofmodes);
charOfModes(1:length(ofmodes)) = upper(charOfModes(1:length(ofmodes)));
ofmodes = cellstr(charOfModes);
OverflowMode.Entries = ofmodes'; 
OverflowMode.ObjectProperty = 'OverflowMode';
OverflowMode.Mode = 1;
OverflowMode.DialogRefresh = 1;


%-----------------------------------------------------------------------
% Third Row contains:
% - ProductMode label widget
% - ProductMode combobox widget
%----------------------------------------------------------------------- 
ProductModeLbl.Name = 'Product mode:';
ProductModeLbl.Type = 'text';
ProductModeLbl.RowSpan = [3 3];
ProductModeLbl.ColSpan = [1 1];
ProductModeLbl.Tag = 'ProductModeLbl';

ProductMode.Name = '';
ProductMode.RowSpan = [3 3];
ProductMode.ColSpan = [2 2];
ProductMode.Tag = 'ProductMode';
ProductMode.Type = 'combobox';
ProductMode.Entries = set(h,'ProductMode')';
ProductMode.ObjectProperty = 'ProductMode';
ProductMode.Mode = 1;
ProductMode.DialogRefresh = 1;
prodmodeVal = h.ProductMode;

%-----------------------------------------------------------------------
% Fourth Row contains:
% - ProductWordLength label widget
% - ProductWordLength edit box widget
%----------------------------------------------------------------------- 
ProductWordLengthLbl.Name = 'Product word length:';
ProductWordLengthLbl.Type = 'text';
ProductWordLengthLbl.RowSpan = [4 4];
ProductWordLengthLbl.ColSpan = [1 1];
ProductWordLengthLbl.Tag = 'ProductWordLengthLbl';

ProductWordLength.Name = '';
ProductWordLength.RowSpan = [4 4];
ProductWordLength.ColSpan = [2 2];
ProductWordLength.Tag = 'ProductWordLength';
ProductWordLength.Type = 'edit';
ProductWordLength.ObjectProperty = 'PrivDDGProductWordLengthString';
ProductWordLength.Mode = 1;
%ProductWordLength.DialogRefresh = 1;
if strcmpi(prodmodeVal,'FullPrecision')
    % Not applicable
    ProductWordLengthLbl.Visible = 0;
    ProductWordLength.Visible = 0;
else
    ProductWordLengthLbl.Visible = 1;
    ProductWordLength.Visible = 1;
end

%-----------------------------------------------------------------------
% Fifth Row contains:
% - MaxProductWordLength label widget
% - MaxProductWordLength edit box widget
%----------------------------------------------------------------------- 
MaxProductWordLengthLbl.Name = 'Maximum product word length:';
MaxProductWordLengthLbl.Type = 'text';
MaxProductWordLengthLbl.RowSpan = [5 5];
MaxProductWordLengthLbl.ColSpan = [1 1];
MaxProductWordLengthLbl.Tag = 'MaxProductWordLengthLbl';

MaxProductWordLength.Name = '';
MaxProductWordLength.RowSpan = [5 5];
MaxProductWordLength.ColSpan = [2 2];
MaxProductWordLength.Tag = 'MaxProductWordLength';
MaxProductWordLength.Type = 'edit';
MaxProductWordLength.ObjectProperty = 'PrivDDGMaxProductWordLengthString';
MaxProductWordLength.Mode = 1;
%MaxProductWordLength.DialogRefresh = 1;
if strcmpi(prodmodeVal,'FullPrecision')
    MaxProductWordLengthLbl.Visible = 1;
    MaxProductWordLength.Visible = 1;
else
    % Not applicable
    MaxProductWordLengthLbl.Visible = 0;
    MaxProductWordLength.Visible = 0;
end 

%----------------------------------------------------------------------- 
% Sixth Row contains:
% - ProductFractionLength label widget
% - ProductFractionLength edit box widget
%-----------------------------------------------------------------------
ProductFractionLengthLbl.Name = 'Product fraction length:';
ProductFractionLengthLbl.Type = 'text';
ProductFractionLengthLbl.RowSpan = [6 6];
ProductFractionLengthLbl.ColSpan = [1 1];
ProductFractionLengthLbl.Tag = 'ProductFractionLengthLbl';

ProductFractionLength.Name = '';
ProductFractionLength.RowSpan = [6 6];
ProductFractionLength.ColSpan = [2 2];
ProductFractionLength.Tag = 'ProductFractionLength';
ProductFractionLength.Type = 'edit';
ProductFractionLength.ObjectProperty = 'PrivDDGProductFractionLengthString';
ProductFractionLength.Mode = 1;
ProductFractionLength.DialogRefresh = 1;
prodBiasVal = h.ProductBias;
prodSAFVal = h.ProductSlopeAdjustmentFactor;
if (strcmpi(prodmodeVal,'SpecifyPrecision') && prodBiasVal==0 && prodSAFVal==1)
    ProductFractionLengthLbl.Visible = 1;
    ProductFractionLength.Visible = 1;
else
    % Not applicable
    ProductFractionLengthLbl.Visible = 0;
    ProductFractionLength.Visible = 0;
end 

%----------------------------------------------------------------------- 
% Seventh Row contains:
% - ProductSlope label widget
% - ProductSlope edit box widget
%-----------------------------------------------------------------------
ProductSlopeLbl.Name = 'Product slope:';
ProductSlopeLbl.Type = 'text';
ProductSlopeLbl.RowSpan = [7 7];
ProductSlopeLbl.ColSpan = [1 1];
ProductSlopeLbl.Tag = 'ProductSlopeLbl';

ProductSlope.Name = '';
ProductSlope.RowSpan = [7 7];
ProductSlope.ColSpan = [2 2];
ProductSlope.Tag = 'ProductSlope';
ProductSlope.Type = 'edit';
ProductSlope.ObjectProperty = 'PrivDDGProductSlopeString';
ProductSlope.Mode = 1;
ProductSlope.DialogRefresh = 1;
prodBiasVal = h.ProductBias;
prodSAFVal = h.ProductSlopeAdjustmentFactor;
if (strcmpi(prodmodeVal,'SpecifyPrecision') && (prodBiasVal~=0 || prodSAFVal~=1))
    ProductSlopeLbl.Visible = 1;
    ProductSlope.Visible = 1;
else
    % Not applicable
    ProductSlopeLbl.Visible = 0;
    ProductSlope.Visible = 0;
end 

%----------------------------------------------------------------------- 
% Eighth Row contains:
% - ProductSlope label widget
% - ProductSlope edit box widget
%-----------------------------------------------------------------------
ProductBiasLbl.Name = 'Product bias:';
ProductBiasLbl.Type = 'text';
ProductBiasLbl.RowSpan = [8 8];
ProductBiasLbl.ColSpan = [1 1];
ProductBiasLbl.Tag = 'ProductBiasLbl';

ProductBias.Name = '';
ProductBias.RowSpan = [8 8];
ProductBias.ColSpan = [2 2];
ProductBias.Tag = 'ProductBias';
ProductBias.Type = 'edit';
ProductBias.ObjectProperty = 'PrivDDGProductBiasString';
ProductBias.Mode = 1;
%ProductBias.DialogRefresh = 1;
prodBiasVal = h.ProductBias;
prodSAFVal = h.ProductSlopeAdjustmentFactor;
if (strcmpi(prodmodeVal,'SpecifyPrecision') && (prodBiasVal~=0 || prodSAFVal~=1))
    ProductBiasLbl.Visible = 1;
    ProductBias.Visible = 1;
else
    % Not applicable
    ProductBiasLbl.Visible = 0;
    ProductBias.Visible = 0;
end 

%-----------------------------------------------------------------------
% Ninth Row contains:
% - SumMode label widget
% - SumMode combobox widget
%----------------------------------------------------------------------- 
SumModeLbl.Name = 'Sum mode:';
SumModeLbl.Type = 'text';
SumModeLbl.RowSpan = [9 9];
SumModeLbl.ColSpan = [1 1];
SumModeLbl.Tag = 'SumModeLbl';

SumMode.Name = '';
SumMode.RowSpan = [9 9];
SumMode.ColSpan = [2 2];
SumMode.Tag = 'SumMode';
SumMode.Type = 'combobox';
SumMode.Entries = set(h,'SumMode')';
SumMode.ObjectProperty = 'SumMode';
SumMode.Mode = 1;
SumMode.DialogRefresh = 1;
summodeVal = h.SumMode;

%-----------------------------------------------------------------------
% Tenth Row contains:
% - SumWordLength label widget
% - SumWordLength edit box widget
%----------------------------------------------------------------------- 
SumWordLengthLbl.Name = 'Sum word length:';
SumWordLengthLbl.Type = 'text';
SumWordLengthLbl.RowSpan = [10 10];
SumWordLengthLbl.ColSpan = [1 1];
SumWordLengthLbl.Tag = 'SumWordLengthLbl';

SumWordLength.Name = '';
SumWordLength.RowSpan = [10 10];
SumWordLength.ColSpan = [2 2];
SumWordLength.Tag = 'SumWordLength';
SumWordLength.Type = 'edit';
SumWordLength.ObjectProperty = 'PrivDDGSumWordLengthString';
SumWordLength.Mode = 1;
%SumWordLength.DialogRefresh = 1;
if strcmpi(summodeVal,'FullPrecision')
    % Not applicable
    SumWordLengthLbl.Visible = 0;
    SumWordLength.Visible = 0;
else
    SumWordLengthLbl.Visible = 1;
    SumWordLength.Visible = 1;
end

%-----------------------------------------------------------------------
% Eleventh Row contains:
% - MaxSumWordLength label widget
% - MaxSumWordLength edit box widget
%----------------------------------------------------------------------- 
MaxSumWordLengthLbl.Name = 'Maximum sum word length:';
MaxSumWordLengthLbl.Type = 'text';
MaxSumWordLengthLbl.RowSpan = [11 11];
MaxSumWordLengthLbl.ColSpan = [1 1];
MaxSumWordLengthLbl.Tag = 'MaxSumWordLengthLbl';

MaxSumWordLength.Name = '';
MaxSumWordLength.RowSpan = [11 11];
MaxSumWordLength.ColSpan = [2 2];
MaxSumWordLength.Tag = 'MaxSumWordLength';
MaxSumWordLength.Type = 'edit';
MaxSumWordLength.ObjectProperty = 'PrivDDGMaxSumWordLengthString';
MaxSumWordLength.Mode = 1;
%MaxSumWordLength.DialogRefresh = 1;
if strcmpi(summodeVal,'FullPrecision')
    MaxSumWordLengthLbl.Visible = 1;
    MaxSumWordLength.Visible = 1;
else
    % Not applicable
    MaxSumWordLengthLbl.Visible = 0;
    MaxSumWordLength.Visible = 0;
end


%-----------------------------------------------------------------------
% Twelveth Row contains:
% - SumFractionLength label widget
% - SumFractionLength edit box widget
%----------------------------------------------------------------------- 
SumFractionLengthLbl.Name = 'Sum fraction length:';
SumFractionLengthLbl.Type = 'text';
SumFractionLengthLbl.RowSpan = [12 12];
SumFractionLengthLbl.ColSpan = [1 1];
SumFractionLengthLbl.Tag = 'SumFractionLengthLbl';

SumFractionLength.Name = '';
SumFractionLength.RowSpan = [12 12];
SumFractionLength.ColSpan = [2 2];
SumFractionLength.Tag = 'SumFractionLength';
SumFractionLength.Type = 'edit';
SumFractionLength.ObjectProperty = 'PrivDDGSumFractionLengthString';
SumFractionLength.Mode = 1;
SumFractionLength.DialogRefresh = 1;
sumBiasVal = h.SumBias;
sumSAFVal = h.SumSlopeAdjustmentFactor;
if (strcmpi(summodeVal,'SpecifyPrecision') && sumBiasVal==0 && sumSAFVal==1)
    SumFractionLengthLbl.Visible = 1;
    SumFractionLength.Visible = 1;
else
    % Not applicable
    SumFractionLengthLbl.Visible = 0;
    SumFractionLength.Visible = 0;
end


%----------------------------------------------------------------------- 
% Thirteenth Row contains:
% - SumSlope label widget
% - SumSlope edit box widget
%-----------------------------------------------------------------------
SumSlopeLbl.Name = 'Sum slope:';
SumSlopeLbl.Type = 'text';
SumSlopeLbl.RowSpan = [13 13];
SumSlopeLbl.ColSpan = [1 1];
SumSlopeLbl.Tag = 'SumSlopeLbl';

SumSlope.Name = '';
SumSlope.RowSpan = [13 13];
SumSlope.ColSpan = [2 2];
SumSlope.Tag = 'SumSlope';
SumSlope.Type = 'edit';
SumSlope.ObjectProperty = 'PrivDDGSumSlopeString';
SumSlope.Mode = 1;
SumSlope.DialogRefresh = 1;
if (strcmpi(summodeVal,'SpecifyPrecision') && (sumBiasVal~=0 || sumSAFVal~=1))
    SumSlopeLbl.Visible = 1;
    SumSlope.Visible = 1;
else
    % Not applicable
    SumSlopeLbl.Visible = 0;
    SumSlope.Visible = 0;
end 

%----------------------------------------------------------------------- 
% Fourteenth Row contains:
% - SumSlope label widget
% - SumSlope edit box widget
%-----------------------------------------------------------------------
SumBiasLbl.Name = 'Sum bias:';
SumBiasLbl.Type = 'text';
SumBiasLbl.RowSpan = [14 14];
SumBiasLbl.ColSpan = [1 1];
SumBiasLbl.Tag = 'SumBiasLbl';

SumBias.Name = '';
SumBias.RowSpan = [14 14];
SumBias.ColSpan = [2 2];
SumBias.Tag = 'SumBias';
SumBias.Type = 'edit';
SumBias.ObjectProperty = 'PrivDDGSumBiasString';
SumBias.Mode = 1;
SumBias.DialogRefresh = 1;
if (strcmpi(summodeVal,'SpecifyPrecision') && (sumBiasVal~=0 || sumSAFVal~=1))
    SumBiasLbl.Visible = 1;
    SumBias.Visible = 1;
else
    % Not applicable
    SumBiasLbl.Visible = 0;
    SumBias.Visible = 0;
end 


%-----------------------------------------------------------------------
% Fifteenth Row contains:
% - CastBeforeSum checkbox widget
%----------------------------------------------------------------------- 
CastBeforeSum.Name = 'Cast before sum';
CastBeforeSum.RowSpan = [15 15];
CastBeforeSum.ColSpan = [1 1];
CastBeforeSum.Type = 'checkbox';
CastBeforeSum.Tag = 'CastBeforeSum';
CastBeforeSum.ObjectProperty = 'CastBeforeSum';
CastBeforeSum.Mode = 1;
CastBeforeSum.DialogRefresh = 1;
if strcmpi(summodeVal,'FullPrecision')
    % Not applicable
    CastBeforeSum.Visible = 0;
else
    CastBeforeSum.Visible = 1;
end

%-----------------------------------------------------------------------
% Assemble main dialog or tab struct
%-----------------------------------------------------------------------  
if ~isTab % is a dialog
 if isa(h,'embedded.globalfimath')
  dlgOrTabStruct.DialogTitle = 'Global Fimath';
 else
  dlgOrTabStruct.DialogTitle = ['embedded.fimath: ' name];
 end
 dlgOrTabStruct.HelpMethod = 'helpview';
 dlgOrTabStruct.HelpArgs   = {[docroot ,'/toolbox/fixedpoint/fixedpoint.map'],...
                      'fimath_dialog'};
else % is a tab
  dlgOrTabStruct.Name = ['embedded.fimath: ' name];
end

dlgOrTabStruct.Items = {RoundModeLbl, RoundMode,...
                   OverflowModeLbl, OverflowMode,...
                   ProductModeLbl, ProductMode,...
                   ProductWordLengthLbl,ProductWordLength,...
                   MaxProductWordLengthLbl,MaxProductWordLength,...
                   ProductFractionLengthLbl,ProductFractionLength,...
                   ProductSlopeLbl,ProductSlope,...
                   ProductBiasLbl,ProductBias,...
                   SumModeLbl, SumMode,...
                   SumWordLengthLbl,SumWordLength,...
                   MaxSumWordLengthLbl,MaxSumWordLength,...
                   SumFractionLengthLbl,SumFractionLength,...
                   SumSlopeLbl,SumSlope,...
                   SumBiasLbl,SumBias,...
                   CastBeforeSum};

dlgOrTabStruct.LayoutGrid = [16 2];
dlgOrTabStruct.RowStretch = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
dlgOrTabStruct.ColStretch = [0 1];


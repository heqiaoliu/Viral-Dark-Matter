function mxdom2word(dom,outputPath)
%MXDOM2WORD Write the DOM out to a Word document.
%   MXDOM2WORD(dom,outputPath)

% Matthew J. Simoneau
% $Revision: 1.1.6.19 $  $Date: 2010/04/21 21:30:56 $
% Copyright 1984-2010 The MathWorks, Inc.

if ~ispc
    error('MATLAB:publish:NoWord','Publishing to Microsoft Word is only supported on the PC.')
end
try
    wordApplication=actxserver('Word.Application');
catch
    error('MATLAB:publish:NoWord','Microsoft Word must be installed to publish to this format.')
end

% Define constants.
wdStyleNormal = -1;
wdStyleHeading1 = -2;
wdStyleHeading2 = -3;
wdFormatDocument = 0;

%set(wordApplication,'Visible',1); % Great for debugging.
documents = wordApplication.Documents;

% Create a new document.  We used to just do
% doc = documents.Add;
% but for some reason this won't work after Notebook runs.  To work around,
% we must do this less satifying two line version:
documents.Add;
doc = documents.Item(documents.Count);

selection = wordApplication.Selection;
try
    style = wordApplication.ActiveDocument.Styles.Add('M-code');
catch
    % This errors if the user already has a style "M-code" defined.  If so, just
    % use that style and continue on.  g274879.
end
try
    set(style,'NoProofing',true);
catch
    % This will fail on Word 97, but it doesn't matter much.
end
set(style.Font,'Name','Lucida Console','Size',8,'Bold',true)
set(style.ParagraphFormat,'LeftIndent',30)

try
    style = wordApplication.ActiveDocument.Styles.Add('output');
catch
    % This errors if the user already has a style "output" defined.  If so, just
    % use that style and continue on.  g312179.
end

try
    set(style,'NoProofing',true);
    set(style.Font,'Color','wdColorGray80')
catch
    % This will fail on Word 97, but it doesn't matter much.
end
set(style.Font,'Name','Lucida Console','Size',8,'Italic',true)

cellNodeList = dom.getElementsByTagName('cell');

[hasIntro,hasSections] = getStructure(cellNodeList);

for i = 1:cellNodeList.getLength
    cellNode = cellNodeList.item(i-1);

    % Table of contents.
    if hasSections && ...
            (((i == 1) && ~hasIntro) || ((i == 2) && hasIntro))
        toc = wordApplication.ActiveDocument.TablesOfContents.Add(selection.Range);
        set(toc,'UpperHeadingLevel',2)
        set(toc,'LowerHeadingLevel',2)
        selection.EndKey;
        selection.MoveDown;
        selection.TypeParagraph;
    end

    % Add title.
    titleNodeList = cellNode.getElementsByTagName('steptitle');
    if (titleNodeList.getLength > 0)
        titleNode = titleNodeList.item(0);
        title = char(titleNode.getFirstChild.getData);
        switch char(titleNode.getAttribute('style'))
            case 'document'
                set(selection,'Style',wdStyleHeading1)
            otherwise
                set(selection,'Style',wdStyleHeading2)
        end
        selection.TypeText(title)
        selection.TypeParagraph;
        set(selection,'Style',wdStyleNormal)
    end

    % Add text.
    textNodeList = cellNode.getElementsByTagName('text');
    if (textNodeList.getLength == 1)
        textNode = textNodeList.item(0);
        addTextNode(textNode,selection,wordApplication,outputPath);
    end

    % Add code.
    mcodeNodeList = cellNode.getElementsByTagName('mcode');
    if (mcodeNodeList.getLength > 0)
        mcode = char(mcodeNodeList.item(0).getFirstChild.getData);
        set(selection,'Style','M-code')
        selection.TypeText(mcode)
        selection.TypeParagraph;
        set(selection,'Style',wdStyleNormal)
        selection.TypeParagraph;
    end

    % Add output text and images.
    childNode = cellNode.getFirstChild;
    while ~isempty(childNode)
        switch char(childNode.getNodeName)
            case 'mcodeoutput'
                addMcodeoutput(selection,childNode,wdStyleNormal)
            case 'img'
                addOutputImaget(selection,childNode)
        end
        childNode = childNode.getNextSibling;
    end
    
end

% Copyright footer.
copyrightList = dom.getElementsByTagName('copyright');
if (copyrightList.getLength > 0)
    copyright = char(copyrightList.item(0).getFirstChild.getData);
    selection.Font.Italic = true;
    selection.TypeText(copyright)
    selection.Font.Italic = false;
end


% Refresh the Table of Contents
if hasSections
    toc.Update;
end

% Return to the top of the document.
%invoke(selection,'GoTo',0);

try
    doc.SaveAs(outputPath,wdFormatDocument);
catch anError
    if ~isempty(strfind(anError.message,'already open elsewhere'))
        str = 'Could not create the file "%s" because there is already a copy open in Word.  Close the document and try again.';
        errordlg(sprintf(str,outputPath),'Publishing Error');
        error(str,outputPath);
    else
        rethrow(anError);
    end
end
doc.Close(0);
wordApplication.Quit


%===============================================================================
function addMcodeoutput(selection,childNode,wdStyleNormal)
% Add m-code output.
mcodeoutput = char(childNode.getFirstChild.getData);
set(selection,'Style','output')
n = numel(mcodeoutput);
frame = 10000;
for i = 1:(n/frame)+1
    firstPosition = (i-1)*frame+1;
    lastPosition = min(i*frame,n);
    selection.TypeText(mcodeoutput(firstPosition:lastPosition))
    disp(i)
end
selection.TypeParagraph;
set(selection,'Style',wdStyleNormal)
selection.TypeParagraph;

%===============================================================================
function addOutputImaget(selection,childNode)
img = char(childNode.getAttribute('src'));
selection.InlineShapes.AddPicture(img);
selection.TypeParagraph;
selection.TypeParagraph;

%===============================================================================
function addTextNode(textNode,selection,wordApplication,outputPath)
textChildNodeList = textNode.getChildNodes;
for j = 1:textChildNodeList.getLength
    textChildNode = textChildNodeList.item(j-1);
    switch char(textChildNode.getNodeName)
        case 'p'
            addText(textChildNode,selection,wordApplication,outputPath)
            selection.TypeParagraph;
            selection.TypeParagraph;
        case {'ul','ol'}
            pChildNodeList = textChildNode.getChildNodes;
            switch char(textChildNode.getNodeName)
                case 'ul'
                    selection.Range.ListFormat.ApplyBulletDefault
                case 'ol'
                    selection.Range.ListFormat.ApplyNumberDefault
            end
            for k = 1:pChildNodeList.getLength
                liNode = pChildNodeList.item(k-1);
                addText(liNode,selection,wordApplication,outputPath)
                selection.TypeParagraph;
            end
            selection.Range.ListFormat.RemoveNumbers;
            selection.TypeParagraph;
        case 'pre'
            font = selection.Font;
            ttProps = {'Name','Size'};
            ttVals = {'Lucida Console',10};
            orig = get(font,ttProps);
            set(font,ttProps,ttVals)
            addText(textChildNode,selection,wordApplication,outputPath)
            set(font,ttProps,orig)
            selection.TypeParagraph;
            selection.TypeParagraph;
        otherwise
            disp(['Not implemented: ' char(textChildNode.getNodeName)])
    end
end

%===============================================================================
function addText(textChildNode,selection,wordApplication,outputPath)
pChildNodeList = textChildNode.getChildNodes;
for k = 1:pChildNodeList.getLength
    pChildNode = pChildNodeList.item(k-1);
    switch char(pChildNode.getNodeName)
        case '#text'
            selection.TypeText(char(pChildNode.getData))
        case {'a','b','i','tt'}
            % Add text recursively and define a range.
            start = selection.Range.Start;
            addText(pChildNode,selection,wordApplication,outputPath)
            activeDocument = wordApplication.ActiveDocument;
            range = activeDocument.Range(start,selection.Range.Start);

            % Range operations can clear the selection's values.  Save them.
            selectionProps = {'Bold','Italic','Name','Size'};
            selectionValues = get(selection.Font,selectionProps);

            % Apply the formatting to the range.
            switch char(pChildNode.getNodeName)
                case 'a'
                    aHref = char(pChildNode.getAttribute('href'));
                    hyperLinks = wordApplication.ActiveDocument.Hyperlinks;
                    hyperLinks.Add(range,aHref,'',aHref);
                case 'b'
                    range.Font.Bold = true;
                case 'i'
                    range.Font.Italic = true;
                case 'tt'
                    range.Font.Name = 'Lucida Console';
                    range.Font.Size = 10;
            end
            
            % Range operations can clear the selection's values.  Restore them.
            set(selection.Font,selectionProps,selectionValues);
            
        case 'img'
            src = char(pChildNode.getAttribute('src'));
            [toInclude,toDelete] = resolvePath(outputPath,src);
            selection.InlineShapes.AddPicture(toInclude);
            delete(toDelete)
        case 'equation'
            equationImage = char(pChildNode.getFirstChild.getAttribute('src'));
            equationText = char(pChildNode.getAttribute('text'));            
            inlineShape = selection.InlineShapes.AddPicture(equationImage);
            inlineShape.AlternativeText = equationText;
        case {'html','latex'}
            % Don't show these in this format.
        otherwise
            disp(['Not implemented: ' char(pChildNode.getNodeName)]);
    end
end


%===============================================================================
function [hasIntro,hasSections] = getStructure(cellNodeList)

hasIntro = false;
if (cellNodeList.getLength > 0)
    style = char(cellNodeList.item(0).getAttribute('style'));
    if isequal(style,'overview')
        hasIntro = true;
    end
end

hasSections = false;
for i = 1:cellNodeList.getLength
    cellNode = cellNodeList.item(i-1);
    titleNodeList = cellNode.getElementsByTagName('steptitle');
    if (titleNodeList.getLength > 0)
        titleNode = titleNodeList.item(0);
        style = char(titleNode.getAttribute('style'));
        if ~isequal(style,'document')
            hasSections = true;
            break
        end
    end
end

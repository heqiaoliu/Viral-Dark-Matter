function htmlOut = matdiff(source1, source2)
% Compares two MAT-files and returns an HTML report showing the differences.
% The inputs must be ComparisonSources and must each have a "readable location"
% property.

% Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4.2.1 $

    [~,fullname1,shortname1,readable1] = i_resolve(source1);
    [~,fullname2,shortname2,readable2] = i_resolve(source2);

    % Make sure that our "short" names are actually different.  If not, use
    % the file name from the readable location, and add directory names
    % until they are different.  This isn't perfect, but is better
    % confusing the user with identical names.
    if strcmp(shortname1,shortname2)
        [pt1,n,e] = fileparts(readable1);
        shortname1 = [n e];
        [pt2,n,e] = fileparts(readable2);
        shortname2 = [n e];
        while strcmp(shortname1,shortname2)
            [pt1,dn1] = fileparts(pt1);
            [pt2,dn2] = fileparts(pt2);
            if isempty(dn1) && isempty(dn2)
                % No more directory names to add.
                % Presumably we're comparing the file with itself.
                break;
            end
            % It doesn't matter if one of dn1 and dn2 is empty, because
            % fullfile won't insert unnecessary separators.
            shortname1 = fullfile(dn1,shortname1);
            shortname2 = fullfile(dn2,shortname2);
        end
    end
    
    % Load the file contents, temporarily suppressing all warnings.
    w = warning('off'); %#ok<WNOFF>
    cleanup = onCleanup(@() warning(w));
    variables1 = load(readable1,'-mat');
    variables2 = load(readable2,'-mat');
    delete(cleanup); % restore warning settings
    names1 = fieldnames(variables1);
    names2 = fieldnames(variables2);

    allnames = unique(vertcat(names1(:),names2(:)));

    doc = com.mathworks.xml.XMLUtils.createDocument('MatFileEditScript');
    root = doc.getDocumentElement;
    title = sprintf('File Comparison - %s vs. %s',shortname1,shortname2);
    i_xmltextnode(doc,root,'Title',title);
    node = i_xmltextnode(doc,root,'LeftLocation',fullname1);
    node.setAttribute('Readable',readable1);
    node.setAttribute('ShortName',shortname1);
    node = i_xmltextnode(doc,root,'RightLocation',fullname2);
    node.setAttribute('Readable',readable2);
    node.setAttribute('ShortName',shortname2);

    for i=1:numel(allnames)
        varname = allnames{i};
        if ~isfield(variables2,varname)
            % Left only
            node = i_xmltextnode(doc,root,'LeftVariable',varname);
            var = variables1.(varname);
            node.setAttribute('size',i_getsize(var));
            node.setAttribute('class',class(var));
        elseif ~isfield(variables1,varname)
            % Right only
            node = i_xmltextnode(doc,root,'RightVariable',varname);
            var = variables2.(varname);
            node.setAttribute('size',i_getsize(var));
            node.setAttribute('class',class(var));
        else
            % Both sides
            node = i_xmltextnode(doc,root,'Variable',varname);
            var1 = variables1.(varname);
            node.setAttribute('leftsize',i_getsize(var1));
            node.setAttribute('leftclass',class(var1));
            var2 = variables2.(varname);
            node.setAttribute('rightsize',i_getsize(var2));
            node.setAttribute('rightclass',class(var2));
            match_type = comparevars(var1,var2);
            node.setAttribute('contentsMatch',match_type);
        end
    end
    
    % Free the memory now that we no longer need it.
    clear variables1;
    clear variables2;

    % If required for debugging purposes, save the edit script to a file.
    schemafile = fullfile(fileparts(mfilename('fullpath')),'matdiff.xsd');
    com.mathworks.comparisons.compare.concr.ListComparisonUtilities.debugSaveXML(doc,schemafile);
    
    stylesheet = fullfile(fileparts(mfilename('fullpath')),'matdiff.xsl');
    xmlsource = com.mathworks.xml.XMLUtils.transformSourceFactory(doc);
    htmlOut = i_doTransform(xmlsource,stylesheet);
end

%------------------------------------------------------------
function htmlOut = i_doTransform(xmlsource,stylesheet)
    propname = 'javax.xml.transform.TransformerFactory';
    oldTransformer = java.lang.System.getProperty(propname);
    java.lang.System.setProperty(propname,'net.sf.saxon.TransformerFactoryImpl');
    err = [];
    try
        stylesource = com.mathworks.xml.XMLUtils.transformSourceFactory(stylesheet);
        writer = java.io.StringWriter;
        result = javax.xml.transform.stream.StreamResult(writer);
        factory = javax.xml.transform.TransformerFactory.newInstance();
        template = factory.newTemplates(stylesource);
        transformer = template.newTransformer();
        % Set Japanese language if necessary.  Default is English.
        lang = java.lang.System.getProperty('user.language');
        if lang.startsWith('ja')
            % This is the name of the folder containing "Comparisons.xml",
            % which contains our Japanese strings.
            transformer.setParameter('language','ja_JP');
        end
        % Supply the path to matlabroot (from which the Javascript file
        % for the sortable table can be found).
        transformer.setParameter('matlabroot',...
            java.io.File(com.mathworks.comparisons.util.MatlabRoot.get()).toURL());
        transformer.transform(xmlsource,result);
        htmlOut = char(writer.toString());
    catch E
        err = E;
    end
    % Restore the original transformer factory.
    if isempty(char(oldTransformer))
        java.lang.System.clearProperty(propname);
    else
        java.lang.System.setProperty(propname,oldTransformer);
    end
    % Report any error which occurred.
    if ~isempty(err)
        rethrow(err);
    end
end

%------------------------------------------------------------
function node = i_xmltextnode(docNode,parentNode,tag,content)
% Creates a simple text tag with the specified contents
    node = docNode.createElement(tag);
    node.appendChild(docNode.createTextNode(content));
    parentNode.appendChild(node);
end

%------------------------------------------------------------
function str = i_getsize(var)
  sz = size(var);
  % We show the number of elements in the same format as the Workspace Browser.
  % See com.mathworks.mlwidgets.workspace.ClassicWhosInformation.getSize
  if numel(sz)==2
      str = sprintf('%dx%d',sz(1),sz(2));
  elseif numel(sz)==3
      str = sprintf('%dx%dx%d',sz(1),sz(2),sz(3));
  else
      % More than 3 dimensions.  Just show number of dimensions.
      str = sprintf('%d-D',numel(sz));
  end
  %info = whos('var');
  %str = sprintf('%s (%d bytes)', str, info.bytes);
end

%------------------------------------------------------------
function [source,fullname,shortname,readable] = i_resolve(source)

    if ischar(source)
        % String supplied.  Treat it as a file name.
        source = resolvePath(source);
        source = com.mathworks.comparisons.source.impl.LocalFileSource(java.io.File(source),source);
    end
    
    absnameprop = com.mathworks.comparisons.source.property.CSPropertyAbsoluteName.getInstance();
    if source.hasProperty(absnameprop)
        fullname = char(source.getPropertyValue(absnameprop,[]));
    else
        % No "absolute name" property.  Just use the "name".
        nameprop = com.mathworks.comparisons.source.property.CSPropertyName.getInstance();
        % All sources have a name
        assert(source.hasProperty(nameprop));
        fullname = char(source.getPropertyValue(nameprop,[]));
    end
    
    shorttitleprop = com.mathworks.comparisons.source.property.CSPropertyShortTitle.getInstance();
    if source.hasProperty(shorttitleprop)
        shortname = char(source.getPropertyValue(shorttitleprop,[]));
    else
        % No "absolute name" property.  Just use the "name".
        nameprop = com.mathworks.comparisons.source.property.CSPropertyName.getInstance();
        % All sources have a name
        assert(source.hasProperty(nameprop));
        shortname = char(source.getPropertyValue(nameprop,[]));
    end
    
    readableprop = com.mathworks.comparisons.source.property.CSPropertyReadableLocation.getInstance();
    % We need a "readable location" property.
    assert(source.hasProperty(readableprop));
    readable = char(source.getPropertyValue(readableprop,[]));
end


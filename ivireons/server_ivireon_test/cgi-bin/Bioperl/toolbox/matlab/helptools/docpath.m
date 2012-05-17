function helpfile = docpath(filename)
    %DOCPATH Obtain the localized path to a file under docroot. 
    %   DOCPATH(FILENAME) Obtain the localized path to a FILENAME under docroot.
    %   If FILENAME doesn't exist under the default localized folder, the 
    %   fallback folder will be checked.  If it doesn't exist in any of the
    %   locations, the function will return an empty array.
    %
    %   For displaying help pages in the Help browser, use HELPVIEW.
    %
    %   This function is unsupported and may change at any time without notice.
    %
    %     Example:
    %        docpath(fullfile(docroot,'techdoc','ref','examples'))
    %
    %     See also HELPVIEW

    %   Copyright 2009 The MathWorks, Inc. 
    %   $Revision: 1.1.6.1 $

    % Make sure that we can support the docpath command on this platform.
    errormsg = javachk('jvm', 'The docpath command');
    if ~isempty(errormsg)
        error('MATLAB:docpath:UnsupportedPlatform', errormsg.message);
    end

    % Obtain the help path to a help file, taking into account localization.
    helpfile = char(com.mathworks.mlservices.MLHelpServices.getLocalizedFilename(filename));
end

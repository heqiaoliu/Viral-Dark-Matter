function importedViews = import(h, filename, conflictOption)

%   Copyright 2009 The MathWorks, Inc.

importedViews = [];
conflictOption = '';

if exist(filename, 'file')
    try
        % Read from file
        readData = load(filename);
        meViewFields = fields(readData);
        if ~isempty(find(cellfun(@(x) ~isempty(strfind(x,'meViews')), meViewFields) == 1))
            meViews  = readData.meViews;
            for i = 1:length(meViews)
                % Create view
                view = DAStudio.MEView(meViews(i).Name, meViews(i).Description);
                if ~isempty(meViews(i).Properties)
                    view.Properties = meViews(i).Properties;
                end
                % Take care of domains.
                if ~isempty(meViews(i).Domain)
                    domainName = meViews(i).Domain;
                    % Create domain and make this view default view.
                    h.createDomain(domainName);                     
                end            
                if isempty(importedViews)
                    importedViews = view;
                else
                    importedViews(end + 1) = view;
                end
            end        
        else
            % disp(['Invalid view definition in file: ' filename]);
        end
    catch loadError                
        disp(['Unable to import: ' loadError.message]);        
    end
end

function loadFIESTAfile(FileName, PathName)
AllObjects = load([PathName FileName], 'Filament');
if ~isfield(AllObjects, 'Filament')
    fJKLoadLink(FileName, PathName, @DF.Load)
    try
        DF.LoadIntensityPerMAP('intensities.txt', PathName)
    catch
        warning('Could not load intensity per MAP file');
    end
else
    AllObjects = AllObjects.Filament;
    NewObjects = select_filaments(AllObjects, 1);
    answer = [];
    if ~all([NewObjects.Drift])
        answer = questdlg('Some Filaments had not been drift-corrected. Continue anyway?', 'Warning', 'Yes','No','Yes' );
        if strcmp(answer, 'No')
            return
        end
    end
    aligned = 1;
    driftcorrected = 1;
    RefObjects = AllObjects([AllObjects.Channel]>1);
    if ~isempty(answer)
        for RefObject = RefObjects;
            if RefObject.TformMat(3,3)==1;
                aligned = 0;
            end
            if RefObject.Drift==0;
                driftcorrected = 0;
            end
        end
        if ~aligned
            answer = questdlg('Some Reference-Filaments had not been color-aligned. Continue anyway?', 'Warning', 'Yes','No','Yes' );
            if strcmp(answer, 'Yes')
                if ~driftcorrected
                    answer = questdlg('Some Reference-Filaments had not been drift-corrected. Continue anyway?', 'Warning', 'Yes','No','Yes' );
                    if strcmp(answer, 'No')
                        return
                    end
                end
            else
                return
            end
        end
    end
    DF.PrepareFils(NewObjects, RefObjects, PathName, FileName);
end
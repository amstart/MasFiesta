function Load(varargin)
global DFDir
if nargin > 0
    FileName = varargin{1};
    PathName = varargin{2};
    switch FileName(end)
        case 'f'
            FilterIndex = 1;
        case 't'
            FilterIndex = 2;
        case 'i'
            FilterIndex = 3;
    end
else
    try
        [FileName, PathName, FilterIndex] = ...
        uigetfile({'*.tif','tif file (*.tif)'; '*.mat','MAT-File (*.mat)'; '*.roi','ImageJ roi (*.roi)'},'Load Objects',DFDir, 'MultiSelect', 'on'); 
    catch
        [FileName, PathName, FilterIndex] = ...
        uigetfile({'*.tif','tif file (*.tif)'; '*.mat','MAT-File (*.mat)'; '*.roi','ImageJ roi (*.roi)'},'Load Objects', 'MultiSelect', 'on');        
    end
end
if FilterIndex
    hDFGui = getappdata(0,'hDFGui');
    if hDFGui.mode == 0
        hDFGui.mode = FilterIndex;
        hDFGui = DF.createSpecialGui(hDFGui);
        setappdata(0,'hDFGui',hDFGui);
    end
    DFDir=PathName;
    switch FilterIndex
        case 1
            DF.loadTIF(FileName, PathName);
        case 2
            DF.loadFIESTAfile(FileName, PathName);
        case 3
            DF.loadROI(FileName, PathName);
    end
end
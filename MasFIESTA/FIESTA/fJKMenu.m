function fJKMenu
        hMainGui=getappdata(0,'hMainGui');
        hDataGui=getappdata(0,'hDataGui');
        if ~isempty(hDataGui)
            if isfield(hDataGui, 'fig')
                if ishandle(hDataGui.fig)
                    if strcmp(get(hDataGui.fig,'Visible'),'on')
                        msgbox('Close Data Gui first please!');
                        return
                    else
                        delete(hDataGui.fig);
                    end
                end
            end
        end
        if ~isempty(hDataGui)
            rmappdata(0,'hDataGui');
        end
        if ~isfield(hMainGui.Extensions, 'JochenK')
            hMainGui.Extensions.JochenK.Util=1;
            hMainGui.Extensions.JochenK.Data=0;
            hMainGui.Extensions.JochenK.DynTags=0;
            hMainGui.Extensions.JochenK.fDataGui=@fDataGui;
            hMainGui.Extensions.JochenK.Kymo=0;
            hMainGui.Extensions.JochenK.TracksKymo=0;
            hMainGui.Extensions.JochenK.ActiveTag=1;
            hDataGui.Extensions.JochenK.DynTags=0;
            hDataGui.Extensions.JochenK.Convert=0;
            hDataGui.Extensions.JochenK.CopyNumber=[];
            setappdata(0,'hDataGui',hDataGui);
            setappdata(0,'hMainGui',hMainGui);
            return
        end
        fJKMenuDiag.fig = dialog('Name','MásFIESTA: Select which modules you want to use','toolbar','none','menu','none');
        fJKMenuDiag.tMenu = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','Position',[0.1 0.75 0.9 0.2],'Style','text', 'FontSize', 12,'HorizontalAlignment','left',...
            'String','This extension provides different modules which you can be used independently from each other. Full changelog can be found in the "Documentation" folder. For questions, contact:', 'TooltipString', ...
            ['There is some added utility at various points in the code which cannot be deactivated (commented with ''JochenK'').']); 
        fJKMenuDiag.eEmail = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','Position',[0.3 0.7 0.4 0.1],'Enable','on','FontSize',8,...
                                     'String','jochen.krattenmacher@web.de','Style','edit','HorizontalAlignment','center');  
        fJKMenuDiag.bInfo = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','Position',[0.35 0.55 0.3 0.1],'Enable','on','FontSize',13,...
                                     'String','Info','HorizontalAlignment','center', 'Callback', @fJKOK, 'UserData', 100);
        fJKMenuDiag.cUtil = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','Position',[0.1 0.5 0.2 0.2], 'String','Utilities','Style','checkbox', 'FontSize', 15,...
            'UserData', 0, 'Callback', @fJKOK, 'Value', hMainGui.Extensions.JochenK.Util, 'Enable', 'Off'); 
        fJKMenuDiag.cKymo = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','Position',[0.1 0.35 0.4 0.2], 'TooltipString',['Flexible Kymographs for multicolor Kymographs with stacks of different lengths. Only works if channel with most frame is channel 1.' ...
            '\n Corrects for color and drift if possible. Uses the file fJKNewKymo.'], 'String','Flexible Multicolor Kymographs','Style','checkbox', 'FontSize', 13,...
            'UserData', 1, 'Callback', @fJKOK, 'Value', hMainGui.Extensions.JochenK.Kymo); 
        fJKMenuDiag.cData = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','Position',[0.1 0.2 0.9 0.2], 'TooltipString',['Uses a different, but quite similar Data GUI with a few more functions and plots.' ...
            ' This GUI was created to handle dynamic filaments. Uses the file fJKDataGui.'], 'String','Different Data GUI','Style','checkbox', 'FontSize', 13,...
            'UserData', 2, 'Callback',@fJKOK, 'Value', hMainGui.Extensions.JochenK.Data); 
        if hMainGui.Extensions.JochenK.Data
            enable = 'on';
        else
            enable = 'off';
        end
        tooltipstr = sprintf(['When switching reference to Start Position, the same bits as usually are used (Tag4, Tag5 and Tag6). \nWhen switching to End Position, Tag7, Tag8 and Tag9 are used (which are otherwise not used currently).']);
        fJKMenuDiag.cDyna = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','enable', enable, 'Position',[0.5 0.275 0.9 0.1], 'TooltipString',tooltipstr, 'String','Filament-End-Associated Tags','Style','checkbox', 'FontSize', 13,...
            'UserData', 3, 'Callback',@fJKOK, 'Value', hMainGui.Extensions.JochenK.DynTags); 
        fJKMenuDiag.bOK = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized',...
               'Position',[0.3 0.1 0.4 0.05],...
               'String','OK','FontSize', 15,...
               'Callback','delete(gcf)');
        fJKMenuDiag.cKymoTracks = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','Position',[0.65 0.35 0.4 0.2], 'TooltipString',['Visualizes additional info about tracks in the kymograph (reference point, tags).' ...
            ''], 'String','+Track Info','Style','checkbox', 'FontSize', 13,...
            'UserData', 4, 'Callback', @fJKOK, 'Value', hMainGui.Extensions.JochenK.TracksKymo); 
        fJKMenuDiag.bConvert = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','Position',[0.5 0.2 0.2 0.05],'Enable','on','FontSize',13, 'TooltipString','Converts ONE tag, more information on click', ...
                                     'String','Convert tags','HorizontalAlignment','center', 'Callback', @fJKOK, 'UserData', 5);
        fJKMenuDiag.bConvertBack = uicontrol('Parent',fJKMenuDiag.fig,'Units','normalized','Position',[0.75 0.2 0.2 0.05],'Enable','on','FontSize',13, 'TooltipString','Converts the tag3 field to vanlla tags, more information on click', ...
                                     'String','Convert back','HorizontalAlignment','center', 'Callback', @fJKOK, 'UserData', 6);

        setappdata(0,'hMainGui',hMainGui);
        setappdata(0,'fJKMenuDiag',fJKMenuDiag);
        hDataGui=getappdata(0,'hDataGui');
        hDataGui.Extensions.JochenK.DynTags=hMainGui.Extensions.JochenK.DynTags;
        setappdata(0,'hDataGui',hDataGui);
end

function fJKOK(popup,~)
    hMainGui=getappdata(0,'hMainGui');
    switch popup.UserData
        case 1
            hMainGui.Extensions.JochenK.Kymo=popup.Value;
        case 2
            fJKMenuDiag=getappdata(0,'fJKMenuDiag');
            hMainGui.Extensions.JochenK.Data=popup.Value;
            hDataGui=getappdata(0,'hDataGui');
            if hMainGui.Extensions.JochenK.Data
                hMainGui.Extensions.JochenK.fDataGui=@fJKDataGui;
                set(fJKMenuDiag.cDyna,'enable','on');
%                 set(fJKMenuDiag.bConv,'enable','on');
            else
                hMainGui.Extensions.JochenK.fDataGui=@fDataGui;
                set(fJKMenuDiag.cDyna,'enable','off');
%                 set(fJKMenuDiag.bConv,'enable','off');
            end
            setappdata(0,'hDataGui',hDataGui);
        case 3
            hMainGui.Extensions.JochenK.DynTags=popup.Value;
            hDataGui=getappdata(0,'hDataGui');
            hDataGui.Extensions.JochenK.DynTags=hMainGui.Extensions.JochenK.DynTags;
            setappdata(0,'hDataGui',hDataGui);
        case 4
            hMainGui.Extensions.JochenK.TracksKymo=popup.Value;
        case 5
            fJKMenuDiag=getappdata(0,'fJKMenuDiag');
            answer = questdlg('Only needs to be done if you ever used "Apply Tags". Only converts the FIRST tag (max value is 15) and puts it into the tag3 field of the new GUI. Continue?', 'Warning', 'Yes','No','Yes' );
            if strcmp(answer, 'Yes')
                fJKConvertTags(1);
                set(fJKMenuDiag.bConvert,'enable','off');
            end
        case 6
            fJKMenuDiag=getappdata(0,'fJKMenuDiag');
            answer = questdlg('Does what "Convert" does, just the other way round (that means only tag3 will be considered). Continue?', 'Warning', 'Yes','No','Yes' );
            if strcmp(answer, 'Yes')
                fJKConvertTags(-1);
                set(fJKMenuDiag.bConvertBack,'enable','off');
            end
        otherwise
            string = sprintf(['Utility additions are:\n -The Dynamic Filaments GUI (found under "Statistics" - load my example files in order to understand it).' ...
                '\n -The Amplitude/Length Statistics GUI (applicable for Molecules as well).' ...
                '\n -The renaming and ordering functionality (access via the right-click menu in the Molecule/Filament lists)'...
                '\n -A Clear Drift option \n -Tracks from locally analysed queues are immediately loaded'...
                '\n -Objects in the list have a green background if they have data in every frame of the channel. They are teal if they don''t miss any frame between their first and last frame.' ...
                '\n -A option to play the stack as a movie by using the edit boxes left from the frame slider (hotkeys are "a" and "s"). You can adjust the frame rate and step size.' ...
                '\n -The Select None/All Button when merging objects' ...
                '\n -The "Subtract Drift" checkbox is now always up-to-date (and is blank if more than one Filament/Molecule is not corrected yet).' ...
                '\n -A "Reload Stack" option.' ...
                '\n -A "Keep Frames" option.' ...
                '\n -An improved GUI for joining Objects.' ...
                '\n -FIESTA asks whether you are sure you want to quit.' ...
                '\n -You can set the save and load folder of FIESTA to be the same.' ...
                '\n -You won''t delete things by pressing the return button anymore.' ...
                '\n -The option to couple Save/load Folders: upon loading a track, the next time you save the folder you used there will be suggested (unless your save folder was within the load folder. And vice versa.']);
            msgbox(string);
    end
    tmp=hMainGui.Extensions.JochenK;
    if tmp.Data||tmp.Kymo
        set(hMainGui.Menu.mJochenK,'Checked','on');
    else
        set(hMainGui.Menu.mJochenK,'Checked','off');
    end
    setappdata(0,'hMainGui',hMainGui);
end
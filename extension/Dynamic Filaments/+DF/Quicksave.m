function Quicksave(varargin)
% global DFDir
% persistent QuicksaveDir
% if nargin>0
%     QuicksaveDir = [];
%     return
% end
% if isempty(QuicksaveDir) || isnumeric(QuicksaveDir)
%     try
%         QuicksaveDir = uigetdir(DFDir, 'Select the quicksave folder (choice will be remembered until you refresh the GUI).');
%     catch 
%         QuicksaveDir = uigetdir('','Select the quicksave folder (choice will be remembered until you refresh the GUI).');
%     end
% end
% if strcmp(get(gcf, 'CurrentCharacter'),'s') && ischar(QuicksaveDir)
%     jFrame = get(handle(gcf),'JavaFrame');
%     jFrame.setMaximized(true);
% %     export_fig([QuicksaveDir filesep strrep(get(gcf, 'Name'), ' | ', '_')], '-png', '-nocrop');
%     filename = strrep(get(gcf, 'Name'), ' | ', '_');
%     optionsstart = strfind(filename, '- ');
%     filename = inputdlg('Filename?', 'Filename?', 1, {[filename(1:optionsstart) ' ']});
%     saveas(gcf,[QuicksaveDir filesep filename{1} '.png'], 'png');
%     savefig(gcf,[QuicksaveDir filesep filename{1} '.fig']);
% %     savefig(gcf,[QuicksaveDir filesep strrep(get(gcf, 'Name'), ' | ', '_') '.fig']);
% end
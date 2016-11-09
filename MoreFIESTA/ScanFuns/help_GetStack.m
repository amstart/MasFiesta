function [ Stack, TimeInfo, PixSize ] = help_GetStack(PathName, field_File)
%Loads the stack (infers its location from the location of the file which
%was loaded by fJKLoadLink and the name of the Stack)
global ScanOptions
if ~isfield(ScanOptions, 'ReplaceFileNamePattern')
     ScanOptions.ReplaceFileNamePattern = fInputDlg({'Fix the string in Object.File field to find the correct stack: replace','with'},{'red', 'green'}, 'noplacefig');
end
StackName = strrep(field_File, ScanOptions.ReplaceFileNamePattern{1}, ScanOptions.ReplaceFileNamePattern{2});
fileseps = findstr(PathName, filesep);
[Stack,TimeInfo,PixSize]=fStackRead([PathName(1:fileseps(end-1)) StackName]);
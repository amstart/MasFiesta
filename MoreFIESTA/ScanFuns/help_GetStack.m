function [ Stack ] = help_GetStack(PathName, field_File)
%Loads the stack (infers its location from the location of the file which
%was loaded by fJKLoadLink and the name of the Stack)
global ScanOptions
StackName = strrep(field_File, ScanOptions.ReplaceFileNamePattern{1}, ScanOptions.ReplaceFileNamePattern{2});
fileseps = findstr(PathName, filesep);
[Stack,~,~]=fStackRead([PathName(1:fileseps(end-1)) StackName]);
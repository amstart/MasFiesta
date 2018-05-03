function [ fullFileName ] = uigetffast()
%UIGETFFAST Summary of this function goes here
%   Detailed explanation goes here
[baseName, folder] = uigetfile('*');
fullFileName = fullfile(folder, baseName);
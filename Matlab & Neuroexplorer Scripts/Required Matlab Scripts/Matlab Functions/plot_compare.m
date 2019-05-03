function [fig] = plot_compare(orig_matrix,cleaned_matrix1,cleaned_matrix2,typelabel1,typelabel2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if nargin <4
    typelabel1=''
    typelabel2=''
end
if nargin < 3
    subrows=2;
else 
    subrows=3;
end
fig = figure;
hold on;
ax1 = subplot(subrows,1,1);
if size(orig_matrix,1)>1
    pcolor(orig_matrix)
else
    plot(orig_matrix')
end

tit = strcat('Orignal Matrix ',typelabel1,'_', typelabel2)
title(tit)
hold off;
ax2 = subplot(subrows,1,2);
hold on;
tit = strcat('Cleaned Matrix v1 ',typelabel1,'_',typelabel2)

title(tit)
if size(cleaned_matrix1,1)>1
    pcolor(cleaned_matrix1)
else 
    plot(cleaned_matrix1')
end
hold off
if nargin >2
    ax3 = subplot(subrows,1,3);
    tit = strcat('Cleaned Matrix v2 ',typelabel1,'_',typelabel2)

    title(tit)
    if size(cleaned_matrix2,1)>1
        pcolor(cleaned_matrix2)
    else
        plot(cleaned_matrix2')
    end
end

% outputArg1 = orig_matrix;
% outputArg2 = cleaned_matrix;
hold off
end


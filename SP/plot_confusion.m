function [  ] = plot_confusion( classes, actual_labels, predicted_labels )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

c = confusionmat(actual_labels,predicted_labels);

cc = c;
for i=1:size(classes,1)
    cc(i,:) = c(i,:)/sum(c(i,:));
end

imagesc(cc)
textStrings = num2str(cc(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:15);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(cc(:) < midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'XTick',1:15, ...
    'YTick',1:15, ...
    'XTickLabel', {classes(:).name}, ...
    'YTickLabel', {classes(:).name});

xtick_rotate([],45,[]);

end


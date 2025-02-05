clear
clc

disp('-----------------------------------------------------------')
disp('|Beware, this code is for GNU Octave ONLY !!!             |')
disp('-----------------------------------------------------------')

%plot the whole session
close all
data=load('microbalance.txt');
time=data(:,1);
Thickness=1000*data(:,2);
plot(time,Thickness,'.k');
xlabel('Time in seconds');
ylabel('Thickness in Angstrom');
set(gca, 'fontsize', 16);
saveas(gcf,'Thickness_vs_time.png');


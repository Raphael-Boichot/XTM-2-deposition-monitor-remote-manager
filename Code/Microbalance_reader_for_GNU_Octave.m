clear
clc
close all

disp('-----------------------------------------------------------')
disp('|Beware, this code is for GNU Octave ONLY !!!             |')
disp('-----------------------------------------------------------')

%%%%%%%%%%%%%%%%%%%%%%%user parameter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
density = '3.970';%4 + point digits mandatory, film density in g/cm3
z_ratio = '0.336';%4 + point digits mandatory, z-ratio in g/cm3
%The z-ratio is a parameter that corrects the frequency change due to acoustic impedance mismatsch between deposited film and crystal
tooling = '100.0';%4 + point digits mandatory, tooling factor in %, take into account real measurements vs the device value, let to 100% by default
fast_mode = 0% fast mode deactivates the plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pkg load instrument-control

%routine to detect microbalance on serial ports
%ACK or char(6) is the default terminator for both read and write
list = serialportlist;
valid_port=[];
for i =1:1:length(list)
    disp(['Testing port COM',num2str(i),'...'])
    s = serialport(char(list(i)),'BaudRate',9600,'DataBits',8,'Parity','none','Stopbits',1);
    set(s, 'timeout',0.1);
    write(s, 'H');
    write(s, char(6));%mandatory terminator
    response=char(read(s, 20));
    if length(response)>0
        if response(1:5)=='XTM/2'
            disp(['Microbalance ' ,response(1:end-1),' detected on port ',char(list(i))])
            valid_port=char(list(i));
        end
    end
    clear s
end

%initialization procedure
s = serialport(valid_port,'BaudRate',9600,'DataBits',8,'Parity','none','Stopbits',1);
set(s, 'timeout',0.1);

%Set the density
mot = ['U 3 1 ',density]; %update density for film 1 (default)
write(s,mot);
write(s, char(6));%mandatory terminator
read(s, 20);%flush serial
write(s,'Q 3 1'); %query density for film 1 (default)
write(s, char(6));%mandatory terminator
response=read(s, 20);
disp(['Density set to: ',char(response(1:end-1)),' g/cm3']);

%Set the z-ratio
mot = ['U 4 1 ',z_ratio]; %update z-ratio for film 1 (default)
write(s,mot);
write(s, char(6));%mandatory terminator
read(s, 20);%flush serial
write(s,'Q 4 1'); %query z-ratio for film 1 (default)
write(s, char(6));%mandatory terminator
response=read(s, 20);
disp(['Z-ratio set to: ',char(response(1:end-1)),' [-]']);

%Set the tooling factor
mot = ['U 0 1 ',tooling]; %update tooling for film 1 (default)
write(s,mot);
write(s, char(6));%mandatory terminator
read(s, 20);%flush serial
write(s,'Q 0 1'); %query tooling for film 1 (default)
write(s, char(6));%mandatory terminator
response=read(s, 20);
disp(['Tooling factor set to: ',char(response(1:end-1)),' %']);

%Set time to zero
write(s, 'R 5');
write(s, char(6));%mandatory terminator
disp('Time set to zero');

%Set Thickness to zero
write(s, 'R 4');
write(s, char(6));%mandatory terminator
disp('Thickness set to zero');

%Measure the crystal life
read(s, 20);%flush serial
write(s,'S 5'); %query tooling for film 1 (default)
write(s, char(6));%mandatory terminator
response=read(s, 20);
disp(['Crystal life: ',char(response(1:end-1)),' %']);

disp('Press x to start and stop measurement')
while (1)
    if (kbhit (1) == 'x')
        break
    end
end

%open the shutter
write(s, 'R 0');
write(s, char(6));%mandatory terminator
disp('Shutter opened');
read(s, 20);%flush serial
disp('Starting acquisition...')
tic
data=[];
time=[];
counter=0;
while (1)
    if (kbhit (1) == 'x')
        break
    end
    counter=counter+1;
    pause(0.1)%no need to spam the serial, microbalance is not able to spit more than 10 points per second
    write(s,'S 2'); %query thickness for film 1 (default)
    write(s, char(6));%mandatory terminator
    time=[time;toc];
    response=ReadToTermination(s,char(6));
    disp(['Thickness: ',char(response(1:end-2)),' µgm']);
    data=[data;str2double(char(response(1:end-2)))];

    if fast_mode==0
        if counter<=100;
            plot(time,data,'bd')
        end
        if counter>100;
            plot(time(end-100:end),data(end-100:end),'bd')
        end
        xlabel('Time in seconds');
        ylabel('Thickness in µgm');
        set(gca, 'fontsize', 16);
        drawnow
    end
end
disp('Stopping acquisition')

%Close the shutter
write(s, 'R 1');
write(s, char(6));%mandatory terminator
disp('Shutter closed');

save_data=[time,data];
save "-ascii" 'microbalance.txt' save_data

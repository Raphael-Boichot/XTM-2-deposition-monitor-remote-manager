clear
clc
close all
disp('-----------------------------------------------------------')
disp('|Beware, this code is for GNU Octave ONLY !!!             |')
disp('|Matlab is not natively able to run it, please update     |')
disp('-----------------------------------------------------------')

%%%%%%%%%%%%%%%%%%%%%%%user parameter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
density = '1.000';%4 + point digits mandatory, film density in g/cm3
z_ratio = '1.000';%4 + point digits mandatory, z-ratio in g/cm3
%The z-ratio is a parameter that corrects the frequency change due to acoustic impedance mismatsch between deposited film and crystal
tooling = '100.0';%4 + point digits mandatory, tooling factor in %, take into account real measurements vs the device value, let to 100% by default
fast_mode = 0;% fast mode deactivates the plot
%DIP Switches configuration : 00000000 00000000 / all zeros, default, no checksum, thickness in kAngstroms
%                             ---GR1-- ---GR2--
%using other configuration may change the protocol or accuracy, adapt the code in consequence, see documentation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pkg load instrument-control

%routine to detect microbalance on serial ports
%ACK or char(6) is the default terminator for both read and write if checksum is not used
list = serialportlist;
valid_port=[];
skip=1;
for i =1:1:length(list)
    disp(['Testing port COM',num2str(i),'...'])
    %the communication protocol details can be set from keys on the front panel, see documentation
    s = serialport(char(list(i)),'BaudRate',9600,'dataBits',8,'Parity','none','Stopbits',1);
    set(s, 'timeout',0.1);
    write(s, 'H');
    write(s, char(6));%mandatory terminator, char(6) is ACK, if something is wrong, the monitor returns NACK + an error code, see documentation
    %here I rely on Timeout to be sure to get all the character string. It's not optimal but the GNU Octave library is not as practical as the Matlab one
    response=char(read(s, 20));
    if ~isempty(response)
        if strcmp(response(1:5),'XTM/2')
            disp(['Microbalance ' ,response(1:end-1),' detected on port ',char(list(i))])%last char is ACK
            valid_port=char(list(i));
            beep ()
            skip=0;
        end
    end
    clear s
end

if skip==0 %microbalance detected
    %initialization procedure
    disp('////////// Initialisation procedure...')
    s = serialport(valid_port,'BaudRate',9600,'dataBits',8,'Parity','none','Stopbits',1);
    set(s, 'timeout',0.1);

    %Set the density and read it back to be sure it is set correctly
    mot = ['U 3 1 ',density]; %update density for film 1 (default)
    write(s,mot);
    write(s, char(6));%mandatory terminator
    read(s, 20);%flush serial
    write(s,'Q 3 1'); %query density for film 1 (default)
    write(s, char(6));%mandatory terminator
    response=read(s, 20);
    disp(['////////// Film density set to: ',char(response(1:end-1)),' g/cm3']);%last char is ACK

    %Set the z-ratio and read it back to be sure it is set correctly
    mot = ['U 4 1 ',z_ratio]; %update z-ratio for film 1 (default)
    write(s,mot);
    write(s, char(6));%mandatory terminator
    read(s, 20);%flush serial
    write(s,'Q 4 1'); %query z-ratio for film 1 (default)
    write(s, char(6));%mandatory terminator
    response=read(s, 20);
    disp(['////////// Z-ratio set to: ',char(response(1:end-1)),' [-]']);%last char is ACK

    %Set the tooling factor and read it back to be sure it is set correctly
    mot = ['U 0 1 ',tooling]; %update tooling for film 1 (default)
    write(s,mot);
    write(s, char(6));%mandatory terminator
    read(s, 20);%flush serial
    write(s,'Q 0 1'); %query tooling for film 1 (default)
    write(s, char(6));%mandatory terminator
    response=read(s, 20);
    disp(['////////// Tooling factor set to: ',char(response(1:end-1)),' %']);%last char is ACK

    %Measure the crystal life (dead crystal is 1MHz variation over about 60 MHz)
    read(s, 20);%flush serial
    write(s,'S 5'); %query tooling for film 1 (default)
    write(s, char(6));%mandatory terminator
    response=read(s, 20);
    disp(['////////// Crystal life: ',char(response(1:end-1)),' % (0% is new, 100% is dead)']);

    %Measure the crystal present frequency
    read(s, 20);%flush serial
    write(s,'S 8'); %query current frequency
    write(s, char(6));%mandatory terminator
    response=read(s, 20);
    initial_frequency=str2double(char(response(1:end-2)));
    disp(['////////// Crystal current frequency: ',char(response(1:end-1)),' Hz']);

    uiwait(msgbox('Balance ready to run measurement (press x on the console to stop)', 'Microbalance status'))

    %Set time to zero
    write(s, 'R 5');
    write(s, char(6));%mandatory terminator
    disp('////////// Timer set to zero');

    %Set Thickness to zero
    write(s, 'R 4');
    write(s, char(6));%mandatory terminator
    disp('////////// Thickness set to zero');
    disp('////////// End of initialisation procedure !')

    %open the shutter
    write(s, 'R 0');
    write(s, char(6));%mandatory terminator
    disp('Shutter opened');
    read(s, 20);%flush serial
    disp('Starting acquisition...')
    tic
    thickness=[];
    time=[];
    counter=0;
    while (1)
        if (kbhit (1) == 'x')
            break
        end
        counter=counter+1;
        pause(0.1)%no need to spam the serial, microbalance is not able to spit more than 10 points per second
        time=[time;toc];
        write(s,'S 2'); %query thickness for film 1 (default)
        write(s, char(6));%mandatory terminator
        %this function is the only way to read the character string fast enough
        response=ReadToTermination(s,char(6));
        disp(['----Time: ',num2str(toc),' Seconds / Thickness: ',char(response(1:end-2)),' kAngstrom----']);
        thickness=[thickness;str2double(char(response(1:end-2)))];

        if fast_mode==0
            if counter<=200
                plot(time,1000*thickness,'dk')%fixed plot
            end
            if counter>200
                plot(time(end-100:end),1000*thickness(end-100:end),'dk')%sliding plot
            end
            xlabel('Time in seconds');
            ylabel('Thickness in Angstrom');
            set(gca, 'fontsize', 16);
            drawnow
        end
    end
    disp('Stopping acquisition')

    %Close the shutter
    write(s, 'R 1');
    write(s, char(6));%mandatory terminator
    disp('Shutter closed');

    %Measure the crystal present frequency
    read(s, 20);%flush serial
    write(s,'S 8'); %query current frequency
    write(s, char(6));%mandatory terminator
    response=read(s, 20);
    final_frequency=str2double(char(response(1:end-2)));
    disp(['Crystal current frequency: ',char(response(1:end-1)),' Hz']);
    disp(['Frequency drift during deposition: ',num2str(final_frequency-initial_frequency),' Hz'])

    %Measure the crystal life (dead crystal is 1MHz variation over about 60 MHz)
    read(s, 20);%flush serial
    write(s,'S 5'); %query tooling for film 1 (default)
    write(s, char(6));%mandatory terminator
    response=read(s, 20);
    disp(['Crystal life: ',char(response(1:end-1)),' % (0% is new, 100% is dead)']);

    %save the data
    save_data=[time,thickness];
    save "-ascii" 'microbalance.txt' save_data

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
else %microbalance not detected
    disp('No matching device found, check connection')
    msgbox('No matching device found, check connection', 'Microbalance status');
end

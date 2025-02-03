clear
clc
close all

disp('-----------------------------------------------------------')
disp('|Beware, this code is for GNU Octave ONLY !!!             |')
disp('-----------------------------------------------------------')

pkg load instrument-control

%routine to detect microbalance on serial ports
%ACK or char(6) is the default terminator for both read and write
list = serialportlist;
valid_port=[];
for i =1:1:length(list)
    disp(['Testing port COM',num2str(i),'...'])
    s = serialport(char(list(i)),'BaudRate',9600,'DataBits',8,'Parity','none','Stopbits',1);
    set(s, 'timeout',1);
    write(s, "H");
    write(s, char(6));
    response=char(read(s, 20));
    if length(response)>0
        if response(1:end-1)=='XTM/2 VERSION 1.50'
            disp(['Microbalance ' ,response(1:end-1),' detected on port ',char(list(i))])
            valid_port=char(list(i));
        end
    end
    clear s
end




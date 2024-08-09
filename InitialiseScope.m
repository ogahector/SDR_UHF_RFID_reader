function inst = InitialiseScope

% visaAddress = 'USB0::0x2A8D::0x1766::MY58493131::0::INSTR'; % old
visaAddress = 'USB0::0x0957::0x17A6::MY52161844::0::INSTR';
% USB[board]::manid::model_code::serial_No[::interface_No]::INSTR			
			

% Connect to the instrument and set the buffer size and instrument timeout
inst = visadev(visaAddress);

inst.InputBufferSize = 10000000; % This may need to be adjusted (depth * 2) + 1 should be enough
inst.Timeout = 10;
inst.ByteOrder = 'little-endian';

fopen(inst);

%Sig_Ch = ['CHAN',num2str(Sig_Ch_Num)];


%fprintf(inst,'*RST; :AUTOSCALE');
% fprintf(inst, '*IDN?')
% fscanf(inst, '%s')



% fprintf(inst,':TIMebase:SCALe 30e-6');
% fprintf(inst,':TIMebase:POSition 180e-6');
fprintf(inst, ':TRIGGER:SOURCE CHAN1');
fprintf(inst, ':TRIGGER:EDGE:SLOPE POSITIVE');
fprintf(inst, ':TRIGGER:LEVEL 0.0');
fprintf(inst, ':TRIGGER:SWEEP NORM');


fprintf(inst,':TIMebase:SCALe 55e-6');
fprintf(inst,':TIMebase:POSition 300e-6');
fprintf(inst, ':TRIGGER:LEVEL 0.5');


fprintf(inst,':CHAN1:IMP FIFTy');
fprintf(inst,':CHAN2:IMP FIFTy');

fprintf(inst,':CHAN2:SCALe 5e-3');


% fprintf(inst,':CHAN1:SCALe 20e-3');
% fprintf(inst,':CHAN3:OFFSet 120e-3');

%CPF1
% fprintf(inst,':CHAN3:SCALe 1e-3');
% fprintf(inst,':CHAN3:OFFSet 4e-3');
% 
% 
% fprintf(inst,':CHAN3:SCALe 50e-3');
% fprintf(inst,':CHAN3:OFFSet 0e-3');

% fwrite(inst, '*cls');
% fwrite(inst, ':single');

% Set the initial instrument parameters
% fprintf(inst, '*RST');
% fprintf(inst, ':stop;:cdis');
% fprintf(inst, '*OPC?'); Junk = str2double(fscanf(inst));
% fprintf(inst, [':', Sig_Ch, ':DISPLAY ON']);
% fprintf(inst, '*OPC?'); Junk = str2double(fscanf(inst));
% fprintf(inst, [':acquire:srate ', num2str(Sample_Rate)]);
% fprintf(inst, ':acquire:srate?')
% fscanf(inst, '%s')

% fprintf(inst, ':TRIGGER:EDGE:SLOPE POSITIVE');
% fprintf(inst, [':TRIGGER:LEVEL ', Sig_Ch, ',0.0']);
% fprintf(inst, ':ACQUIRE:MODE RTIME');
% fprintf(inst, [':AUTOSCALE:VERTICAL ', Sig_Ch]);
% fprintf(inst, '*OPC?'); Junk = str2double(fscanf(inst));

fclose(inst);

end
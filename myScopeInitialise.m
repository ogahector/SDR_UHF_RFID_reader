function inst = myScopeInitialise

visaAddress = 'USB0::0x0957::0x17A6::MY52161844::0::INSTR'; % <- personalize
% USB[board]::manid::model_code::serial_No[::interface_No]::INSTR			
			
% Connect to the instrument and set the buffer size and instrument timeout
inst = visadev(visaAddress);

inst.InputBufferSize = 10000000; % This may need to be adjusted (depth * 2) + 1 should be enough
inst.Timeout = 10;
inst.ByteOrder = 'little-endian';

fopen(inst);

% Setup channel impedances
writeline(inst,':CHAN1:IMP FIFTy');
writeline(inst,':CHAN2:IMP FIFTy');
writeline(inst,':CHAN3:IMP FIFTy');
writeline(inst,':CHAN4:IMP FIFTy');

% Frame Setup in ScopeSetupFrame(inst)
% Data fetch in ScopeFetchData

%% no idea what this does but im assuming its important so im keeping it here

% fwrite(inst, '*cls');
% fwrite(inst, ':single');

% Set the initial instrument parameters
% writeline(inst, '*RST');
% writeline(inst, ':stop;:cdis');
% writeline(inst, '*OPC?'); Junk = str2double(query(inst));
% writeline(inst, [':', Sig_Ch, ':DISPLAY ON']);
% writeline(inst, '*OPC?'); Junk = str2double(query(inst));
% writeline(inst, [':acquire:srate ', num2str(Sample_Rate)]);
% writeline(inst, ':acquire:srate?')
% query(inst, '%s')

% writeline(inst, ':TRIGGER:EDGE:SLOPE POSITIVE');
% writeline(inst, [':TRIGGER:LEVEL ', Sig_Ch, ',0.0']);
% writeline(inst, ':ACQUIRE:MODE RTIME');
% writeline(inst, [':AUTOSCALE:VERTICAL ', Sig_Ch]);
% writeline(inst, '*OPC?'); Junk = str2double(query(inst));

% fclose(inst); % not used anymore

end
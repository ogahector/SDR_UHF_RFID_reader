// REWRITING IT SO THAT IT WORKS hopefully?  though useless, it makes me understand how it works

#include<Arduino.h>

#define TARI 20 // between 6.25 and 20 microseconds
#define PW (unsigned)TARI/2 // between max(0.265*TARI, 2) and 0.525*TARI microseconds
#define L0 (unsigned) TARI  // TARI
#define L1 (unsigned) (2*TARI) // between 1.5 and 2 TARI
#define RTCAL L0+L1
#define TRCAL (unsigned)(3*(RTCAL)) // 1.1 to 3 RTCAL
#define DR 8000
#define BLF (unsigned)(DR/TRCAL)
#define TRESH 16000/BLF // 16e6 = ATmega328P clock freq
#define TRESH_L (unsigned) (0.75*TRESH) // between 0.5 and 1; should be 0.75
#define TRESH_H (unsigned) (1.5*TRESH) // between 1 and 1.5; should be 1.25
#define CLR(x,y) (x &= (~(1<<y)))
#define SET(x,y) (x |= (1<<y))

// GLOBAL VARIABLES
byte command[22];
byte answer[160];
unsigned int timing[320];
int i_glob, j_glob;

// DECLARE / IMPORT FUNCTIONS
// all commands must be capital
void preamble();
void sync();
void send_data_0();
void send_data_1();
void RTcal();
void TRcal();
void Query(); // original code's 
void QUERY(byte M, byte TRext, byte Sel, byte session, byte target, byte q);
void SELECT(int target, int action, int memBank, int pointer, byte length, int mask, bool trunc);
void QueryRep(int session);
void ACK(byte frame[]);
void NAK(byte frame[]);
int check_crc16(byte PC[], byte EPC[], byte CRC[]);
void read_answer(int timeout);
void send_command(byte frame[], int length);
void print_command(byte frame[], int length);
void timer1_setup(byte mode, int prescale, byte outmode_A, byte outmode_B, byte capture_mode);

// SETUP
void setup()
{
    int i = 0;

    Serial.begin(9600);

    pinMode(11, OUTPUT);
    digitalWrite(11, HIGH);

    pinMode(8, INPUT);

    for(i = 0; i < 160; i++) answer[i] = 0;
    for(i = 0; i < 320; i++) timing[i] = 0;

    timer1_setup(0, 1, 0, 0, 0);

    Serial.println("RFID Reader V1.0");
    Serial.print("TARI = ");
    Serial.println(TARI);
    Serial.print("PW = ");
    Serial.println(PW);
    Serial.print("L0 = ");
    Serial.println(L0);
    Serial.print("L1 = ");
    Serial.println(L1);
    Serial.print("RTCAL = ");
    Serial.println(RTCAL);
    Serial.print("TRCAL = ");
    Serial.println(TRCAL);
    Serial.print("PIE Rate = ");
    Serial.print(2./(RTCAL)*1e3);
    Serial.println(" kb/s");
    Serial.print("BLF = ");
    Serial.print(BLF);
    Serial.println(" kb/s");
    Serial.print("TRESH_L: ");
    Serial.print(TRESH_L);
    Serial.print(" | TRESH_H: ");
    Serial.println(TRESH_H);
}

void loop()
{
    int i;
    int pt = 0;
    // unsigned int time2, ptime2 = 0xFFFF;
    // float T1rn, T1epc;
    // float T2;
    // float Tpri0, Tpri1, Tpracc, Tpri0acc, Tpri1acc;
    // int nTpri

    // byte RN16[16];
    int RN16;
    // byte PC[16];
    int PC;
    byte EPC[96];
    // byte CRC[16];
    int CRC;

    delay(500);

    Query();

    read_answer(int(10 + 22.5) * 1./BLF*1e3); // WHY THIS SPECIFIC TIME??

    // find violation and locate ourselves 2 ahead
    for(i = 0; i < 7; i++)
    {
        if(answer[i] == 2) 
        {
            pt = i + 2;
            break;
        }
    }
    if(i == 7)  // reset
    {
        for(i = 0; i < 160; i++)
        {
            answer[i] = 0;
        }
        i_glob = 0;
        j_glob = 0;
        return;
    }

    // read RN16
    for(i = RN16 = 0; i < 16; i++)
    {
        RN16 |= answer[pt + i] << (16 - i - 1);
    }

    ACK(RN16);

    read_answer(5000); // also why?? this should be compliant but so specific...

    for(i = 0; i < 7; i++)
    {
        if(answer[i] == 2)
        {
            pt = i + 2;
            break;
        }
    }


}

// DEFINE FUNCTIONS
// define them as inline if necessary later

void send_data_0()
{
    SET(PORTB, 3);
    delayMicroseconds(TARI-PW+2);
    CLR(PORTB, 3);
    delayMicroseconds(PW);
    SET(PORTB, 3);
}

void send_data_1()
{
    SET(PORTB, 3);
    delayMicroseconds(L1-PW+2);
    CLR(PORTB, 3);
    delayMicroseconds(PW);
    SET(PORTB, 3);
}

void send_command(byte frame[], int length)
{
    for(int i = 0; i < length; i++)
    {
        if(frame[i] == 0) send_data_0;
        else if(frame[i] == 1) send_data_1;
    }
}

void send_command_int(unsigned long int command, int length)
{
    for(int i = sizeof(command) - 1; i > sizeof(command) - length; i++)
    {
        if ((command >> i) & 1 == 1) send_data_1;
        else if ((command >> i) & 1 == 0) send_data_0;
    }
}

void RTcal()
{
    SET(PORTB, 3);
    delayMicroseconds(RTCAL-PW+2);  //data_0 + data_1
    CLR(PORTB, 3);
    delayMicroseconds(PW);
    SET(PORTB, 3);
}

void TRcal()
{
    SET(PORTB, 3);
    delayMicroseconds(TRCAL-PW+2); 
    CLR(PORTB, 3);
    delayMicroseconds(PW);
    SET(PORTB, 3);
}

void read_answer(int timeout)
{
    TIFR1 = 1<<5;
    TIMSK1 = 1<<5;
    TCNT1 = 0;
    delayMicroseconds(timeout);
    TIFR1 = 0<<5;
    TIMSK1 = 0<<5;
}

void preamble()
{
    CLR(PORTB, 3);
    delayMicroseconds(12);
    send_data_0();
    RTcal();
    TRcal();
    SET(PORTB, 3);
}

void sync()
{
    CLR(PORTB, 3);
    delayMicroseconds(12);
    send_data_0();
    RTcal();
    SET(PORTB, 3);
}

void QUERY(byte M, byte TRext, byte Sel, byte session, byte target, byte q)
{
    unsigned long int command;
    // if(DR != 8000) command |= 0x0800; // => DR = 64/3
    // command |= (M & 0b111) << 15; // enforce field width
    // command |= (TRext & 0b1) << 14;
    // command |= (Sel & 0b11) << 12;
    // command |= (session & 0b11) << 10;
    // command |= (target & 0b1) << 9;
    // command |= (q & 0b1111) << 5;
    // command |= 0b10000; // CRC-5

    command = (0x8 << 18) | ( (DR != 8000) & 1 << 17 ) | ((M & 0b111) << 15) | 
              ((TRext & 0b1) << 14) | (Sel & 0b11) << 12 | ((session & 0b11) << 10) | 
              (command |= (target & 0b1) << 9) | (command |= (q & 0b1111) << 5) | 0b10000;
    preamble();
    send_command_int(command, 22);
}

void ACK(int RN16)
{
    sync();
    send_command_int(0b10, 2);
    send_command_int(RN16, 16);
}

void NAK()
{
    sync();
    send_command_int(0x00, 8);
}

int check_crc16(int PC, byte EPC[], int CRC)
{
    int i, j;
    byte reg[16];
    byte gen[17] = {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
    byte res[16] = {0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 1, 1};
    byte pre[16] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
    
    byte trame[144];
    int error = 0;
    
    for (i = 0; i < 144; i++)
        trame[i] = 0;
    for (i = 0; i < 16; i++)
        trame[i] = (PC << (16 - i - 1)) & 1;
    for (i = 0; i < 96; i++)
        trame[i+16] = EPC[i];
    for (i = 0; i < 16; i++)
        trame[i+112] = (CRC << (16 - i - 1)) & 1; 

    for (i = 0; i < 16; i++)
        if (pre[i])
        reg[i] = trame[i] ? 0:1;  //preset

    for (i = 16; i < 144; i++)
    {
        if (reg[0] == 1)
        {
        for (j= 0; j < 15; j++)
            reg[j] = (reg[j+1] + gen[j+1])%2;
        reg[15] = (trame[i]+ gen[16])%2;
        }
        else
        {
        for (j = 0; j < 15; j++)
            reg[j] = reg[j+1];
        reg[15] = trame[i];
        }
    }
    for (i = 0; i < 16; i++)
    {
        if (reg[i] != res[i])
        {
        error = 1;
        break;
        }
    }
    Serial.println("Successfully finished CRC16 Check");
    return error;
}
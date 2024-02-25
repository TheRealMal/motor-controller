// Headers definitions
const char HTTPheader[] = "HTTP/1.1 200 OK\nContent-type:";
const char HTTPMimeTypeHTML[] = "text/html\n\n";
const char HTTPMimeTypeScript[] = "text/plain\n\n";
const unsigned int delay = 80;
// Index HTML page definition
char IndexPage[] =
"<html><body><form name=\"input\" method=\"get\">\
<table align=center width=500 bgcolor=#acfffff border=4>\
<tr><td align=center colspan=2><font size=7 color=Black face=\"verdana\">\
<b>MOTOR CONTROL</b></font></td></tr><tr><td align=center bgcolor=#acfffff>\
<input name=\"TA\" type=\"submit\" value=\"Left\"></td><td align=center bgcolor=#acfffff>\
<input name=\"TB\" type=\"submit\" value=\"Right\"></td></tr><tr>\
<td align=center bgcolor=#acfffff colspan=1><input name=\"+\" type=\"submit\" value=\"+\">\
</td><td align=center bgcolor=#acfffff colspan=1>\
<input name=\"-\" type=\"submit\" value=\"-\"></td></tr><tr>\
<td align=center bgcolor=#acfffff colspan=2><input name=\"stop\" type=\"submit\" value=\"Stop\">\
</td></tr></table></form>\
<script src=\"\" async defer></script></body></html>";

// Ethernet NIC interface definitions
sfr sbit SPI_Ethernet_Rst   at RC0_bit;
sfr sbit SPI_Ethernet_CS    at RC1_bit;
sfr sbit SPI_Ethernet_Rst_Direction at TRISC0_bit;
sfr sbit SPI_Ethernet_CS_Direction  at TRISC1_bit;

unsigned char MACAddr[6] = {0x00, 0x14, 0xA5, 0x76, 0x19, 0x3f};
unsigned char IPAddr[4] = {192,168,0,20};
unsigned char getRequest[10];

typedef struct {
    unsigned canCloseTCP:1;
    unsigned isBroadcast:1;
} TethPktFlags;


/*
    TCP routine. This is where the user request to toggle LED A or LED B are processed
*/
unsigned int SPI_Ethernet_UserTCP(unsigned char *remoteHost, unsigned int remotePort, unsigned int localPort, unsigned int reqLength, TEthPktFlags *flags) {
    unsigned int length;
    for (length=0; length<10; ++length) {
        getRequest[length]=SPI_Ethernet_getByte();
    }
    getRequest[length]=0;

    if (memcmp(getRequest, "GET /", 5)){
        return(0);
    }

    if (!memcmp(getRequest + 6, "TA", 2)){
       while(1){
                PORTB = 0b0001;
                Delay_ms(delay);
                PORTB = 0b0010;
                Delay_ms(delay);
                PORTB = 0b0100;
                Delay_ms(delay);
                PORTB = 0b1000;
                Delay_ms(delay);
       }

    } else if (!memcmp(getRequest + 6, "TB", 2)) {
        PORTB = 0b1000;
        Delay_ms(delay);
        PORTB = 0b0100;
        Delay_ms(delay);
        PORTB = 0b0010;
        Delay_ms(delay);
        PORTB = 0b0001;
        Delay_ms(delay);
        
        PORTB = 0b1000;
        Delay_ms(delay);
        PORTB = 0b0100;
        Delay_ms(delay);
        PORTB = 0b0010;
        Delay_ms(delay);
        PORTB = 0b0001;
        Delay_ms(delay);
    }

    if (localPort != 80) {
        return(0);
    }

    length = SPI_Ethernet_putConstString(HTTPheader);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putString(IndexPage);
    return length;
}

/*
    UDP routine. Must be declared even though it is not used
*/
unsigned int SPI_Ethernet_UserUDP(unsigned char *remoteHost, unsigned int remotePort, unsigned int destPort, unsigned int reqLength, TEthPktFlags *flags) {
    return(0);
}

/*
    Main program
*/
void main() {
    OSCCON = 0b00000001;
    TRISB = 0x00;
    PORTB = 0x00;
    ANSELC = 0; // Configure PORTC as digital
    ANSELD = 0; // Configure PORTD as digital
    TRISD = 0; // Configure PORTD as output
    PORTD = 0;
    SPI1_Init(); // Initialize SPI module
    SPI_Ethernet_Init(MACAddr, IPAddr, 0x01); // Initialize Ethernet module

    while(1) {
        SPI_Ethernet_doPacket(); // Process next received packet
    }
}
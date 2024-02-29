// Headers definitions
const char HTTPheader[] = "HTTP/1.1 200 OK\nContent-type:";
const char HTTPMimeTypeHTML[] = "text/html\n\n";
const char HTTPMimeTypeScript[] = "text/plain\n\n";

// Ethernet NIC interface definitions
sfr sbit SPI_Ethernet_Rst at RC0_bit;
sfr sbit SPI_Ethernet_CS at RC1_bit;
sfr sbit SPI_Ethernet_Rst_Direction at TRISC0_bit;
sfr sbit SPI_Ethernet_CS_Direction at TRISC1_bit;

unsigned char MACAddr[6] = {0x00, 0x14, 0xA5, 0x76, 0x19, 0x3f};
unsigned char IPAddr[4] = {10, 211, 55, 5};
unsigned char getRequest[10];

typedef struct {
  unsigned canCloseTCP : 1;
  unsigned isBroadcast : 1;
} TEthPktFlags;

typedef struct {
  int motor_type;
  int running;
  int right;
  int delay;
  int tick_counter;
  int steps_counter;
  int port_value;
} Config;

Config cfg = {0, 0, 0, 40, 0, 0, 0};

/*
    TCP routine. This is where the user request to toggle LED A or LED B are
   processed
*/
unsigned int SPI_Ethernet_UserTCP(unsigned char *remoteHost,
                                  unsigned int remotePort,
                                  unsigned int localPort,
                                  unsigned int reqLength, TEthPktFlags *flags) {
  unsigned int length;
  for (length = 0; length < 10; ++length) {
    getRequest[length] = SPI_Ethernet_getByte();
  }
  getRequest[length] = 0;

  if (memcmp(getRequest, "GET /", 5)) {
    return (0);
  }

  if (!memcmp(getRequest + 6, "DLEFT", 5)) {
    cfg.right = 0;
  } else if (!memcmp(getRequest + 6, "DRIGHT", 6)) {
    cfg.right = 1;
  } else if (!memcmp(getRequest + 6, "STOP", 4)) {
    cfg.running = 0;
  } else if (!memcmp(getRequest + 6, "START", 5)) {
    cfg.running = 1;
  } else if (!memcmp(getRequest + 6, "SDECR", 5)) {
    cfg.delay += 10;
  } else if (!memcmp(getRequest + 6, "SINCR", 5) && cfg.delay > 40) {
    cfg.delay -= 10;
  } else if (!memcmp(getRequest + 6, "MSTEP", 5)) {
    cfg.motor_type = 0;
  } else if (!memcmp(getRequest + 6, "MASYNC", 6)) {
    cfg.motor_type = 1;
  }

  if (localPort != 80) {
    return (0);
  }

  length = SPI_Ethernet_putConstString(HTTPheader);
  length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
  return length;
}

void HandleMotor() {
  int new_port_value = 0b0000;
  if (cfg.running == 0) {
    cfg.port_value = new_port_value;
    // cfg.steps_counter = 10;
    return;
  }
  /*
  if (cfg.steps_counter == 0){
       cfg.port_value = 0b0000;
       cfg.steps_counter = 10;
       cfg.running = 0;
       return;
  }
  */
  switch (cfg.right) {
  case 0:
    new_port_value |= 0b0100;
    break;
  case 1:
    new_port_value &= 0b1011;
    break;
  }
  cfg.port_value = new_port_value;
}

/*
    UDP routine. Must be declared even though it is not used
*/
unsigned int SPI_Ethernet_UserUDP(unsigned char *remoteHost,
                                  unsigned int remotePort,
                                  unsigned int destPort, unsigned int reqLength,
                                  TEthPktFlags *flags) {
  return (0);
}

/*
    Main program
*/
void main() {
  OSCCON = 0b0111000;
  TRISB = 0x00;
  TRISA = 0x00;
  PORTB = 0b0000;
  PORTA = 0x0000;
  ANSELC = 0; // Configure PORTC as digital
  ANSELD = 0; // Configure PORTD as digital
  TRISD = 0;  // Configure PORTD as output
  PORTD = 0;
  SPI1_Init();                              // Initialize SPI module
  SPI_Ethernet_Init(MACAddr, IPAddr, 0x01); // Initialize Ethernet module
  while (1) {
    SPI_Ethernet_doPacket(); // Process next received packet
    HandleMotor();
    ++cfg.tick_counter;
    if (cfg.tick_counter == cfg.delay) {
      cfg.port_value ^= 0b1000;
      cfg.tick_counter = 0;
      //--cfg.steps_counter;
    }
    PORTB = cfg.port_value;
  }
}
// Headers definitions
const char HTTPheaderErr[] = "HTTP/1.1 400 Bad Request\nAccess-Control-Allow-Origin:*\nContent-type:";
const char HTTPheader[] = "HTTP/1.1 200 OK\nAccess-Control-Allow-Origin:*\nContent-type:";
const char HTTPMimeTypeHTML[] = "text/html\n\n";
const char OKStatus[] = "OK";
const char FormatError[] = "Wrong command format";
const char OptionError[] = "Wrong option";
const char SpeedError[] = "Failed to parse speed";
const char AngleError[] = "Failed to parse angle";
// Ethernet NIC interface definitions
sfr sbit SPI_Ethernet_Rst at RC0_bit;
sfr sbit SPI_Ethernet_CS at RC1_bit;
sfr sbit SPI_Ethernet_Rst_Direction at TRISC0_bit;
sfr sbit SPI_Ethernet_CS_Direction at TRISC1_bit;

unsigned char MACAddr[6] = {0x00, 0x14, 0xA5, 0x76, 0x19, 0x3f};
unsigned char IPAddr[4] = {10, 211, 55, 5};
unsigned char getRequest[20];

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
  int angle;
  int angle_half;
  int is_half_step;
  int steps_counter;
  int port_value;
} Config;

Config cfg = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void emptyCfg() {
  cfg.motor_type = 0;
  cfg.running = 0;
  cfg.right = 0;
  cfg.delay = 0;
  cfg.tick_counter = 0;
  cfg.angle = 0;
  cfg.angle_half = 0;
  cfg.is_half_step = 0;
  cfg.steps_counter = 0;
  cfg.port_value = 0;
}

void HandleStepperMotor() {
  int new_port_value = 0b0000;
  if (cfg.running) {
    new_port_value |= 0b0001;
  }
  new_port_value = 0b0001;
  if (cfg.is_half_step == 1) {
    new_port_value |= 0b0010;
  }
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

void run() {
  while (cfg.running) {
    if (cfg.motor_type == 0) {
      HandleStepperMotor();
      ++cfg.tick_counter;
      if (cfg.tick_counter >= cfg.delay) {
        cfg.port_value ^= 0b1000;
        cfg.tick_counter = 0;
        ++cfg.steps_counter;
      }
      PORTB = cfg.port_value;
      if (cfg.is_half_step == 0 && cfg.steps_counter == cfg.angle) {
        if (cfg.angle_half == 0) {
          emptyCfg();
          continue;
        }
        cfg.is_half_step = 1;
        cfg.steps_counter = 0;
      } else if (cfg.is_half_step == 1 && cfg.steps_counter == cfg.angle_half) {
        emptyCfg();
      }
    } else if (cfg.motor_type == 1) {
      return;
    }
  }
}

/*
    TCP routine. This is where the user request to toggle LED A or LED B are
   processed
*/
unsigned int SPI_Ethernet_UserTCP(unsigned char *remoteHost,
                                  unsigned int remotePort,
                                  unsigned int localPort,
                                  unsigned int reqLength, TEthPktFlags *flags) {
  unsigned int length;
  char* freqEnd;
  int angleStart;
  
  for (length = 0; length < 20; ++length) {
    getRequest[length] = SPI_Ethernet_getByte();
  }
  getRequest[length] = 0;

  if (memcmp(getRequest, "GET /", 5)) {
    return (0);
  }
  if (localPort != 80) {
    return (0);
  }
  
  if (!memcmp(getRequest + 5, "OFF", 3)) {
    emptyCfg();
    length = SPI_Ethernet_putConstString(HTTPheader);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(OKStatus);
    return length;
  }
  /*
    ST - Stepper
    AC - Async
  */
  if (!memcmp(getRequest + 5, "ST", 2)) {
    cfg.motor_type = 0;
  } else if (!memcmp(getRequest + 5, "AC", 2)) {
    cfg.motor_type = 1;
  } else {
    length = SPI_Ethernet_putConstString(HTTPheaderErr);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(OptionError);
    return length;
  }

  // "," symbol
  if (memcmp(getRequest + 7, ",", 1)) {
    length = SPI_Ethernet_putConstString(HTTPheaderErr);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(FormatError);
    return length;
  }

  /*
    R - Right
    L - Left
  */
  if (!memcmp(getRequest + 8, "R", 1)) {
    cfg.right = 1;
  } else if (!memcmp(getRequest + 8, "L", 1)) {
    cfg.right = 0;
  } else {
    length = SPI_Ethernet_putConstString(HTTPheaderErr);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(OptionError);
    return length;
  }

   // "," symbol
  if (memcmp(getRequest + 9, ",", 1)) {
    length = SPI_Ethernet_putConstString(HTTPheaderErr);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(FormatError);
    return length;
  }

  // Parses frequency from request
  cfg.delay = atoi(getRequest + 10);
  if (cfg.delay == 0) {
    length = SPI_Ethernet_putConstString(HTTPheaderErr);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(SpeedError);
    return length;
  }
  cfg.delay = 18512 / cfg.delay;

  // Parses angle from request
  freqEnd = strchr(getRequest + 10, ',');
  angleStart = (int)(freqEnd - getRequest) + 1;
  cfg.angle = atoi(getRequest + angleStart);
  if (cfg.angle == 0) {
    length = SPI_Ethernet_putConstString(HTTPheaderErr);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(AngleError);
    return length;
  }
  
  switch (cfg.motor_type)
  {
  case 0:
    ++cfg.angle;
    cfg.angle_half = (int)((float) cfg.angle / 1.8);
    if (((float) cfg.angle / 1.8) - (float)cfg.angle_half > 0.0) {
      cfg.angle_half = 1;
    } else {
      cfg.angle_half = 0;
    }
    cfg.angle = (int)((float) cfg.angle / 1.8);
    break;
  case 1:
    break;
  }

  cfg.running = 1;
  run();
  length = SPI_Ethernet_putConstString(HTTPheader);
  length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
  length += SPI_Ethernet_putConstString(OKStatus);
  return length;
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
  PORTB = 0b0000;
  ANSELC = 0; // Configure PORTC as digital
  SPI1_Init();                              // Initialize SPI module
  SPI_Ethernet_Init(MACAddr, IPAddr, 0x01); // Initialize Ethernet module
  while (1) {
    SPI_Ethernet_doPacket(); // Process next received packet
  }
}
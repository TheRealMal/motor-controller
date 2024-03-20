// Объявление заголовков и статусов
const char HTTPheaderErr[] = "HTTP/1.1 400 Bad Request\nAccess-Control-Allow-Origin:*\nContent-type:";
const char HTTPheader[] = "HTTP/1.1 200 OK\nAccess-Control-Allow-Origin:*\nContent-type:";
const char HTTPMimeTypeHTML[] = "text/html\n\n";
const char OKStatus[] = "OK";
const char FormatError[] = "Wrong command format";
const char OptionError[] = "Wrong option";
const char SpeedError[] = "Failed to parse speed";
const char AngleError[] = "Failed to parse angle";

// Интерфейсы для работы с Ethernet
sfr sbit SPI_Ethernet_Rst at RC0_bit;
sfr sbit SPI_Ethernet_CS at RC1_bit;
sfr sbit SPI_Ethernet_Rst_Direction at TRISC0_bit;
sfr sbit SPI_Ethernet_CS_Direction at TRISC1_bit;

unsigned char MACAddr[6] = {0x00, 0x14, 0xA5, 0x76, 0x19, 0x3f};
unsigned char IPAddr[4] = {10, 211, 55, 5};
unsigned char getRequest[20];

unsigned int async_step = 0;
unsigned int motor_speed, i, j;

// Структура для работы с Ethernet
typedef struct {
  unsigned canCloseTCP : 1;
  unsigned isBroadcast : 1;
} TEthPktFlags;

// Структура текущих конфигураций
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

// Инициализация конфигурационной переменной
Config cfg = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

// Функция для очистки конфигурационной переменной
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

// ----------------------------------------
//  Асинхронный мотор
// ----------------------------------------

// Управления рабочим циклом ШИМа
void set_pwm_duty(unsigned int pwm_duty)
{
  CCP1CON = ((pwm_duty << 4) & 0x30) | 0x0C;
  CCPR1L  = pwm_duty >> 2;
}

// Функция инициализации выходов для асинхронного двигателя
void initAsync() {
  TRISD = 0;
  PORTD = 0;
  INTCON = 0xC0;
  C1IF_bit = 0;
  CCP1CON = 0x0C;
  CCPR1L = 0;
  set_pwm_duty((unsigned int) cfg.delay);
}

// Обработка шагов асинхронного двигателя
void asyncMove()
{
  switch(async_step){
    case 0:
      CCP1CON = 0;      // Выкл ШИМ
      PORTD   = 0x08;
      PSTRCON = 0x08;   // Выход ШИМ на RD7
      CCP1CON = 0x0C;   // Вкл ШИМ
      CM1CON0 = 0xA2;   // BEMF C
      break;
    case 1:
      PORTD = 0x04;
      CM1CON0 = 0xA1;   // BEMF B
      break;
    case 2:
      CCP1CON = 0;      // Выкл ШИМ
      PORTD   = 0x04;
      PSTRCON = 0x04;   // Выход ШИМ на RD6
      CCP1CON = 0x0C;   // Вкл ШИМ
      CM1CON0 = 0xA0;   // BEMF A
      break;
    case 3:
      PORTD = 0x10;
      CM1CON0 = 0xA2;   // BEMF C
      break;
    case 4:
      CCP1CON = 0;      // Выкл ШИМ
      PORTD   = 0x10;
      PSTRCON = 0x02;   // Выход ШИМ на RD5
      CCP1CON = 0x0C;   // Вкл ШИМ
      CM1CON0 = 0xA1;   // BEMF B
      break;
    case 5:
      PORTD = 0x08;
      CM1CON0 = 0xA0;   // BEMF A
      break;
  }
  async_step++;
  if(async_step >= 6)
    async_step = 0;
}

// Обработчик движения асинхронным потором
void HandleAsyncMotor() {
  int i = cfg.angle;
  while(i > 0)
  {
    j = cfg.delay;
    while(j--) ;
    asyncMove();
    i = i - 1;
  }
}

// ----------------------------------------
//  Шаговый мотор
// ----------------------------------------

// Обработчик движения шаговым потором
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

// Обработка команды на основе полученной
// конфигурации
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
      initAsync();
      HandleAsyncMotor();
      emptyCfg();
    }
  }
}

unsigned int parse_command(unsigned int length) {
  char* freqEnd;
  int angleStart;
  if (!memcmp(getRequest + 5, "OFF", 3)) {
    emptyCfg();
    length = SPI_Ethernet_putConstString(HTTPheader);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(OKStatus);
    return length;
  }
  /*
    ST - Шаговый
    AC - Асинхронный
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

  // "," символ
  if (memcmp(getRequest + 7, ",", 1)) {
    length = SPI_Ethernet_putConstString(HTTPheaderErr);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(FormatError);
    return length;
  }

  /*
    R - Вправо
    L - Влево
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

   // "," символ
  if (memcmp(getRequest + 9, ",", 1)) {
    length = SPI_Ethernet_putConstString(HTTPheaderErr);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(FormatError);
    return length;
  }

  // Достает число из запроса, которое отвечает за скорость
  cfg.delay = atoi(getRequest + 10);
  if (cfg.delay == 0) {
    length = SPI_Ethernet_putConstString(HTTPheaderErr);
    length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
    length += SPI_Ethernet_putConstString(SpeedError);
    return length;
  }
  if (!cfg.motor_type) {
     cfg.delay = 18512 / cfg.delay;
  }

  // Достает число из запроса, которое отвечает за угол поворота
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
    cfg.angle *= 10;
    break;
  }
  return 0;
}

// Обработчик Ethernet TCP запросов
unsigned int SPI_Ethernet_UserTCP(unsigned char *remoteHost,
                                  unsigned int remotePort,
                                  unsigned int localPort,
                                  unsigned int reqLength, TEthPktFlags *flags) {
  unsigned int length;
  
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
  length = parse_command(length);
  if (length != 0) {
    return length
  }
  cfg.running = 1;
  run();
  length = SPI_Ethernet_putConstString(HTTPheader);
  length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
  length += SPI_Ethernet_putConstString(OKStatus);
  return length;
}

// Обработчик Ethernet UDP запросов; Нужен для корректной работы
unsigned int SPI_Ethernet_UserUDP(unsigned char *remoteHost,
                                  unsigned int remotePort,
                                  unsigned int destPort, unsigned int reqLength,
                                  TEthPktFlags *flags) {
  return (0);
}

// Основная функция
void main() {
  ANSELA = 0x10;
  OSCCON = 0b0111000;
  TRISB = 0x00;
  PORTB = 0b0000;
  ANSELC = 0;
  
  SPI1_Init();                              // Инициализация SPI модуля
  SPI_Ethernet_Init(MACAddr, IPAddr, 0x01); // Инициализация Ethernet модуля
  while (1) {
    SPI_Ethernet_doPacket(); // Обработка следующего пакета
  }
}
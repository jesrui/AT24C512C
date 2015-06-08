/*
  EEPROM512.pde
  AT24C512C EEPROM Benchmark Sketch 
  
  Find on GitHub:
  https://github.com/husio-org/AT24C512C
  
  The Atmel� AT24C512C provides 524,288 bits of Serial Electrically Erasable and
  Programmable Read-Only Memory (EEPROM) organized as 65,536 words of eight bits
  each. The cascadable feature of the device allows up to eight devices to share a
  common 2-wire bus. The device is optimized for use in many industrial and commercial
  applications where low-power and low-voltage operation are essential. The devices are
  available in space-saving 8-lead JEDEC SOIC, 8-lead EIAJ SOIC, 8-lead TSSOP,
  8-pad UDFN, 8-ball WLCSP, and 8-ball VFBGA packages. In addition, the entire family
  is available in 1.7V (1.7V to 3.6V) and 2.5V (2.5V to 5.5V) versions.
  
  http://www.atmel.com/Images/Atmel-8720-SEEPROM-AT24C512C-Datasheet.pdf

  Address Map, and Storage Capability

  Address = A2..A0 P8..P0 B6..B0

  2^3 devices = 8 devices (A bits)
  2^9 pages = 512 pages (P bits)
  2^7 bytes = 128 bytes (B bits)

  2^16 bytes per device = 64 Kbytes per device
  2^19 bytes with all 8 devices = 512Kbytes max storage capability

  == Connections with the Arduino Uno Rev. 3

  In this example two AT24C512C chips are connected to the arduino at I2C
  addresses 0x50 and 0x51:

  For the first device, connect as follows:
  EEPROM 4 (GND) to GND
  EEPROM 8 (Vcc) to Vcc (5 Volts)
  EEPROM 5 (SDA) to Arduino SDA
  EEPROM 6 (SCL) to Arduino SCL
  EEPROM 7 (WP)  to GND
  EEPROM 1 (A0)  to GND
  EEPROM 2 (A1)  to GND
  EEPROM 3 (A2)  to GND
  The first devide will thus be at address 0x50

  For the second device:
  EEPROM 4 (GND) to GND
  EEPROM 8 (Vcc) to Vcc (5 Volts)
  EEPROM 5 (SDA) to Arduino SDA
  EEPROM 6 (SCL) to Arduino SCL
  EEPROM 7 (WP)  to GND
  EEPROM 1 (A0)  to Vcc
  EEPROM 2 (A1)  to GND
  EEPROM 3 (A2)  to GND
  The second devide will thus be at address 0x51

*/

#include <Wire.h>
#include <AT24C512C.h>

unsigned long time;
unsigned long finishTime;
unsigned long errors = 0;
unsigned long address = 0;

// Set to a higher number if you don't want to start at the beginning of the EEPROM 
#define MIN_ADDRESS0 0
#define MIN_ADDRESS1 0x0010000

// Maximum address (inclusive) in address space.  Choose one.
// It should be: 0x000XFFFF Where X is 0-7 for 1 to 8 devices

#define MAX_ADDRESS0 0x000001FF // test first 512 bytes of first device
#define MAX_ADDRESS1 0x00101FF  // test first 512 bytes of second device

void setup()
{
  Serial.begin(9600);
  Serial.println();
  Serial.println("AT24C512C Library Benchmark Sketch");
  Serial.println();

  // write "abc...." to the first device at 0x50
  writeByByteTest(MIN_ADDRESS0, MAX_ADDRESS0, 'a');
  readByByteTest(MIN_ADDRESS0, MAX_ADDRESS0, 'a');

  // write "bcd...." to the second device at 0x51
  writeByByteTest(MIN_ADDRESS1, MAX_ADDRESS1, 'b');
  readByByteTest(MIN_ADDRESS1, MAX_ADDRESS1, 'b');
}

void loop()
{
}

void writeByByteTest(unsigned long start_address, unsigned long end_address,
                     uint8_t start_data)
{
  time = millis();
  errors = 0;
  Serial.println("--------------------------------");
  Serial.print("Write By Byte Test: start_address 0x");
  Serial.print(start_address,HEX);
  Serial.print(", end_address 0x");
  Serial.print(end_address,HEX);
  Serial.println();
  Serial.print("Writing data:");
  for (address = start_address; address <= end_address; address++)
  {
    EEPROM512.write(address, start_data++);
    if (!(address % 100))
      Serial.print(".");
  }
  finishTime = millis() - time;
  Serial.println("DONE");
  Serial.print("Total Time (seconds): "); 
  Serial.println((unsigned long)(finishTime / 1000));
  Serial.print("Write operations per second: "); 
  Serial.println((end_address-start_address)/(finishTime / 1000)); 
  Serial.println("--------------------------------");   
  Serial.println();
}

void readByByteTest(unsigned long start_address, unsigned long end_address,
                    uint8_t start_data)
{
  time = millis();
  errors = 0;
  Serial.println("--------------------------------");
  Serial.print("Read By Byte Test: start_address 0x");
  Serial.print(start_address,HEX);
  Serial.print(", end_address 0x");
  Serial.print(end_address,HEX);
  Serial.println();
  Serial.print("Reading data:");
  for (address = start_address; address <= end_address; address++)
  {
    uint8_t data = EEPROM512.read(address);
    if (data != start_data)
    {
      Serial.println();
      Serial.print("Address: 0x");
      Serial.print(address,HEX);
      Serial.print(" Should be: ");
      Serial.print(start_data, DEC);
      Serial.print(" Read val: ");
      Serial.println(data, DEC);
      errors++;
    }
    if (!(address % 100))
      Serial.print(".");
    start_data++;
  }
  finishTime = millis() - time;
  Serial.println("DONE");
  Serial.println();
  Serial.print("Total Test Time (secs): "); 
  Serial.println((unsigned long)(finishTime / 1000));
  Serial.print("Read operations per second: "); 
  Serial.println((end_address-start_address)/(finishTime / 1000)); 
  Serial.print("Total errors: ");
  Serial.println(errors);
  Serial.println("--------------------------------");
  Serial.println();
}



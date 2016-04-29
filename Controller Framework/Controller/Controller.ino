#define LCHECK 10
int lastRead;
boolean connection;
void setup() {
  // put your setup code here, to run once:
  connection = false;
  Serial.begin(9600);
  lastRead = 0;
  int led = 2;
  pinMode(2, INPUT_PULLUP);
  pinMode(3, INPUT_PULLUP);
  pinMode(4, INPUT_PULLUP);
  pinMode(5, INPUT_PULLUP);
}
void loop() {
  // put your main code here, to run repeatedly:
  if (connection) {
    if (digitalRead(2) == LOW) Serial.println("a");
    if (digitalRead(3) == LOW) Serial.println("b");
    if (digitalRead(4) == LOW) Serial.println("c");
    if (digitalRead(5) == LOW) Serial.println("d");
    if (round(analogRead(A0) / 10.23) - lastRead != 0) {
      lastRead = round(analogRead(A0) / 10.23);
      Serial.println("V1" + String(lastRead));
    }
  }
  if (Serial.available > 0){
    readSerial();
  }
}

void readSerial(){
  String input;
  while (Serial.available > 0){
    input += char(Serial.read());
  }
  switch (input){
    case "RETURN TYPE":
    Serial.println("rhCon");
    break;
    case "START":
    connection = true;
    break;
  }
}


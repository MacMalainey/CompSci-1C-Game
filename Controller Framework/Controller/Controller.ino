#define LCHECK 10
boolean connection;
void setup() {
  // put your setup code here, to run once:
  connection = false;
  Serial.begin(9600);
  lastRead = 0;
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


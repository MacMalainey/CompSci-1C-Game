import processing.serial.*;
Serial ardu;
boolean setupFailed;
StringDict keys = new StringDict();
int timer;
//HELD
//OFF
//PRESSED
void setup() {
  timer = 0;
  setupFailed = !(grabController());
  size(600, 1000);
  textAlign(CENTER);
  keys.set("a", "OFF");
  keys.set("b", "OFF");
  keys.set("c", "OFF");
  keys.set("d", "OFF");
  keys.set("V1", "0");
  keys.set("V2", "0");
  fill(255);
}

void draw() {
  background(0);
  if (setupFailed) {
    if (millis() - timer >= 10000) {
      setupFailed = !(grabController());
      timer = millis();
    }
    text("Controller not found", 300, 200);
    text("Please plug in controller", 300, 400);
    text("Retrying in " + int((10000 - (millis() - timer)) * 0.001) + " seconds", 300, 600);
  } else {
    if (ardu.available() > 0) {
      read();
    }
    ellipseMode(CENTER);
    if (keys.get("a").equals("HELD")) fill(255, 0, 0); else fill(255);
    ellipse(120, 200, 100, 100);
    if (keys.get("b").equals("HELD")) fill(255, 0, 0); else fill(255);
    ellipse(240, 200, 100, 100);
    if (keys.get("c").equals("HELD")) fill(255, 0, 0); else fill(255);
    ellipse(360, 200, 100, 100);
    if (keys.get("d").equals("HELD")) fill(255, 0, 0); else fill(255);
    ellipse(480, 200, 100, 100);
  }
}

void read() {
  String controller = ardu.readString();
  switch (controller) {
  case "a":
    break;
  case "b":
    break;
  case "c":
    break;
  case "d":
    break;
  default:
    if ((str(controller.charAt(0)) + str(controller.charAt(1))).equals("V1")){
      //Ahh, im certain if i had lambdas, this would be a whole lot better
      
    } else if ((str(controller.charAt(0)) + str(controller.charAt(1))).equals("V2")){
    } else {
      println("hey man, you did something wrong");
    }
  }
}


boolean grabController() {
  boolean res = false;
  if (Serial.list().length > 0) {
    for (String item : Serial.list()) {
      Serial test = new Serial(this, item, 9600);
      test.write("RETURN TYPE");
      int timerSerial = millis();
      while (millis() - timerSerial < 2000) {
        if (test.available() > 0) {
          String input = test.readString();
          println(input);
          if (input.equals("rhCon")) {
            ardu = new Serial(this, item, 9600);
            res = true;
          }
        }
      }
      test.clear();
      test.stop();
    }
  }
  return res;
}
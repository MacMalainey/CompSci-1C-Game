int cursor;  //yOffset
int state;
StringList logs = new StringList();
PrintWriter logFile = createWriter("Log:" + str(day()) + "_" + str(month()) + "_" + str(year()));
ArrayList<note> notes = new ArrayList<note>();
ArrayList<song> songsList = new ArrayList<song>();
boolean held = false;
ArrayList<File> songsDir = new ArrayList<File>();
void setup(){
  size(750, 900);
  cursor = 0;
  state = 0;
  selectFolder("hello sir", "folderSelected");
}
void folderSelected(File selected){
  if (selected != null) println(selected.getAbsolutePath());
  else println("incompelete");
}
void draw(){
  switch (state){
    case 0:
    break;
    case 1:
    for(note item : notes){
      item.move();
      item.art();
    }
    break;
  }
  if(logs.size() > 0){
    logProcess(logs.array());
    logs.clear();
  }
  if (!mousePressed && held){
    held = false;
  }
}
class button{
  color cProp;
  button(){
  }
  void hover(){
  }
  void pressed(){
    if (mousePressed && !held){
      held = true;
    }
  }
}

class song{
  song(){
  }
  void display(){
  }
}

class note{
  int column;
  int y;
  boolean success;
  note(int time, int where){
    y = time;
    column = where;
    success = false;
  }
  void move(){
    y--;
  }
  void art(){
    
  }
}

void logProcess(String[] output){
  for(String item : output){
    logFile.println("[" + str(hour()) + ":" + str(minute()) + ":" + str(second()) + "]: " + item);
  }
}
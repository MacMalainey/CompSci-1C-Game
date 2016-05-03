int cursor;  //yOffset
int state;
StringList logs = new StringList();
PrintWriter logFile = createWriter("Log " + str(day()) + " " + str(month()) + " " + str(year()) + ".log");
ArrayList<note> notes = new ArrayList<note>(); //stores notes in game
ArrayList<song> songsList = new ArrayList<song>();  //stores songs objects
boolean held = false; //used to make sure mouseclicked commands dont repeat
ArrayList<File> songsDir = new ArrayList<File>();//stores folder files for directory
ArrayList<button> GUI = new ArrayList<button>();//stores the buttons
boolean[] keys =  new boolean[4];//holds the keys
int[] scroll = new int[2];
void setup(){
  size(750, 900);
  cursor = 0;
  state = 0;
  loadMainGUI();
  loadSongDirectories();
}
void spawnNotes(){
  //Iterate through song notes and make a class for each one
  //Every note needs to be made in this format:
  //notes.add(new note(int column, int time, int held);
}
void saveSongDirectories(){
  //Loads the song directories from a file
  StringList store = new StringList();
  for(File item : songsDir){
    store.append(item.getAbsolutePath());
    logs.append("Adding directory: " + item.getAbsolutePath() + " to directory list");
  }
  saveStrings("bMapDir.list", store.array());
}

void loadSongDirectories(){ //loads through beatmap file, first checks if it exists
  boolean changes = false;
  if ((new File(sketchPath("bMapDir.list")).exists())){
    for (String item : loadStrings("bMapDir.list")){
      File directory = new File(item);
      if (directory.exists()){
        songsDir.add(directory);
        logs.append("Adding directory on path: " + item + " to list");
      } else {
        changes = true;
        logs.append("Song directory " + item + " does not exist");
      }
    }
    if (changes){
      logs.append("Re-writing song directory list, files listed have been altered");
      saveSongDirectories();
    }
  } else {
    createWriter("bMapDir.list");
    logs.append("bMapDir.list not found, creating file");
  }
}

void loadMainGUI(){ //creates GUI objects needed for the main screen
  GUI.clear();
  GUI.add(new button(width - 100, height - 70, "import"));
  GUI.add(new button(width - 100, height - 200, "play"));
}

void folderSelected(File selected){ //used for importing 
  boolean duplicates = false;
  for (File item : songsDir){
    if (item.getAbsolutePath().equals(selected.getAbsolutePath())) duplicates = true;
  }
  if (selected != null && !duplicates){
    songsDir.add(selected);
    saveSongDirectories();
    logs.append("Added Directory: " + selected.getAbsolutePath());
    logs.append("Refreshing song list");
    loadSongs();
  } else if (selected != null && duplicates){
    logs.append("File: " + selected.getAbsolutePath() + " was already included in directory list");
  } else logs.append("Import cancelled");
}

void loadSongs(){  //loads songs in songs array
  for (File item : songsDir){
    for (File it2 : item.listFiles()){
      String fileExt = "";
      String path = it2.getName();
      for (int itemChar = path.length() - 1; path.charAt(itemChar) != '.'; itemChar--){
        fileExt += str(path.charAt(itemChar));
        if (fileExt.equals("bMap")){
          songsList.add(new song(it2.getAbsolutePath()));
          logs.append("LOADED BEATMAP: " + path);
        }
      }
    }
  }
}

void draw(){
  background(90,0, 90);
  switch (state){
    case 0:
    textSize(40);
    textAlign(CENTER);
    fill(255);
    text("COMPSCI 1C RHYTHM BEAT", width/2, 50);
    break;
    case 1:
    for(note item : notes){
      item.move();
      item.art();
    }
    break;
  }
  for(button item : GUI){
    item.hover();
    switch(item.pressed()){
      case "import":
      selectFolder("Select folder containing beatmaps to import", "folderSelected");
      break;
      case "start":
      logs.append("Starting game. IF IT WAS MADE");
      break;
      case "back":
      logs.append("Heading back to main menu");
      loadMainGUI();
      state = 0;
      break;
    }
    item.art();
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
  int x;
  int y;
  String title;
  button(int xA, int yA, String text){
    x = xA;
    y = yA;
    title = text;
    cProp = color(0, 0, 200);
  }
  void art(){
    fill(cProp);
    rectMode(CENTER);
    rect(x, y, 150, 70);
    fill(255);
    textSize(20);
    text(title, x, y);
  }
  void hover(){
    if (abs(mouseX - x) <= 75 && abs(mouseY - y) <= 35) cProp = color(0, 0, 150);
    else cProp = color(0, 0, 200);
  }
  String pressed(){
    if (mousePressed && abs(mouseX - x) <= 75 && abs(mouseY - y) <= 35) cProp = color(100, 100, 255);
    if (mousePressed && !held && abs(mouseX - x) <= 75 && abs(mouseY - y) <= 35){
      held = true;
      return title;
    } else return "false";
  }
}
StringDict parseMeta(String path){  //parse through the metadata of the songs
  
  return null;
} 
class song{ //stores song properties
  StringDict properties;
  song(String path){
  properties = parseMeta(path);
  }
  void display(){
  }
}

class note{
  int column;
  int y;
  boolean success;
  int held;
  note(int where, int time, int stop){
    y = time;
    column = where;
    held = stop;
    success = false;
  }
  void move(){
    y--;
  }
  void art(){
    
  }
}

void logProcess(String[] output){ //prints out logs to a file every loop
  for(String item : output){
    logFile.println("[" + str(hour()) + ":" + str(minute()) + ":" + str(second()) + "]: " + item);
    println(item);
  }
}

void keyTyped(){  //PLEASE PROPERLY EXIT THE SKETCH BY PRESSING 't' IF YOU WANT THE DEBUG TO APPEAR PROPERLY
  if (key == 't'){
    logFile.flush();
    logFile.close();
    exit();
  }
}

void keyPressed(){
  if (key == 'a'){
    keys[0] = true;
  } else if (key == 's'){
    keys[1] = true;
  } else if (key == 'l'){
    keys[2] = true;
  } else if (key == ';'){
    keys[3] = true;
  }
}

void keyReleased(){
  if (key == 'a'){
    keys[0] = false;
  } else if (key == 's'){
    keys[1] = false;
  } else if (key == 'l'){
    keys[2] = false;
  } else if (key == ';'){
    keys[3] = false;
  }
}
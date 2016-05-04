int cursor;  //yOffset
int state;
StringList logs = new StringList();
PrintWriter logFile;
ArrayList<note> notes = new ArrayList<note>(); //stores notes in game
ArrayList<song> songsList = new ArrayList<song>();  //stores songs objects
boolean held = false; //used to make sure mouseclicked commands dont repeat
ArrayList<File> songsDir = new ArrayList<File>();//stores folder files for directory
ArrayList<button> GUI = new ArrayList<button>();//stores the buttons
boolean[] keys =  new boolean[4];//holds the keys
slist GUIlist;
void setup(){
  logFile = createWriter(sketchPath() + "/logs/Log " + str(day()) + " " + str(month()) + " " + str(year()) + ".log");
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
  loadSongs();
}

void loadMainGUI(){ //creates GUI objects needed for the main screen
  GUI.clear();
  GUI.add(new button(width - 100, height - 70, "import"));
  GUI.add(new button(width - 100, height - 200, "play"));
  GUIlist = new slist();
}

void loadPlayGUI(){ //creates GUI objects needed for play screen
}

void folderSelected(File selected){ //used for importing 
  if (selected != null){
    boolean duplicates = false;
    for (File item : songsDir){
      if (item.getAbsolutePath().equals(selected.getAbsolutePath())) duplicates = true;
    }
    if (!duplicates){
      songsDir.add(selected);
      saveSongDirectories();
      logs.append("Added Directory: " + selected.getAbsolutePath());
      logs.append("Refreshing song list");
      loadSongs();
    } else if (duplicates){
      logs.append("File: " + selected.getAbsolutePath() + " was already included in directory list");
    } else logs.append("Import cancelled");
  }
}

void loadSongs(){  //loads songs in songs array
  songsList.clear();
  for (File item : songsDir){
    for (File it2 : item.listFiles()){
      String fileExt = "";
      String path = it2.getName();
      for (int itemChar = path.length() - 1; path.charAt(itemChar) != '.'; itemChar--){
        fileExt += str(path.charAt(itemChar));
        if (fileExt.equals("paMb")){  //The way im inputing to the string makes it backwards....  Whoops
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
    GUIlist.display();
    GUIlist.selection();
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
class slist{
  int scroll;
  int pressed;
  int scrollDisplay;
  slist(){
    scroll = 0;
    pressed = -1;
  }
  void display(){
    rectMode(CORNER);
    fill(230);
    fill(50);
    rect(510, 190, 40, 540);
    if (songsList.size() > 0){
      if (10/songsList.size() < 1){
        fill(0);
        rect(510, 190, 40, 540);
      } else {
        fill(230);
        rect(510, 190, 40, 540);
      }
    }
    fill(0);
    rect(30, 150, 480, 620);
    if (songsList.size() <= 10){
      fill(50);
      rect(510, 150, 40, 40);
      rect(510, 730, 40, 40);
      fill(200);
      triangle(510, 150, 550, 150, 530, 190);
      triangle(510, 770, 550, 770, 530, 730);
    } else {
      fill(230);
      rect(510, 150, 40, 40);
      rect(510, 730, 40, 40);
      fill(150);
      triangle(510, 150, 550, 150, 530, 190);
      triangle(510, 770, 550, 770, 530, 730);
    }
    if (pressed - scroll >= 0 && pressed - scroll < 10  && pressed < songsList.size()){
      fill(200);
      rect(30, 150 + (62 * (pressed - scroll)), 480, 63);
    }
    if (songsList.size() > 0){
      for(int item = scroll; item < scroll + 10; item++){
        if (item >= songsList.size()) break;
        song display = songsList.get(item);
        textAlign(LEFT, TOP);
        fill(255);
        textSize(17);
        text(display.returnPath(), 30, 150 + (62 * (item - scroll)));
        textAlign(CENTER);
      }
    }
  }
  void selection(){
    if(mousePressed && !held && abs(mouseX - 300) <= 270 && abs(mouseY - 460) <= 310){
      held = true;
      if(songsList.size() > 10){
        if (abs(mouseX - 530) <= 20 && abs(mouseY - 170) <= 20){
          if(scroll + 10 < songsList.size()) scroll++;
        } else if (abs(mouseX - 530) <= 20 & abs(mouseY - 750) <= 20){
          if(scroll > 0) scroll--;
        }
      }
      if (abs(270 - mouseX) <= 240 && abs(460 - mouseY)<= 310){
       pressed = scroll + int((mouseY - 150)/62);
      }
    }
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
  String[] loadedmap = loadStrings(path);
  StringDict meta = new StringDict();
  for (String item : loadedmap){
    boolean keyDone = false;
    String result = "";
    for (int index = 0; index < item.length(); index++){
      if (item.charAt(index) == ':' && keyDone );
      result+= str(item.charAt(index));
    }
  }
  return null;
} 
class song{ //stores song properties
  StringDict properties;
  song(String path){
  properties = new StringDict();
 // properties = parseMeta(path);
  properties.set("path", path);
  }
  void display(int x, int y){
    textAlign(LEFT);
    text(properties.get("path"), x, y);
    textAlign(CENTER);
  }
  String returnPath(){
    return properties.get("path");
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
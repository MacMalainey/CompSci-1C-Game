int cursor;  //yOffset
int state; //game state
StringList logs = new StringList();
PrintWriter logFile;
ArrayList<note> notes = new ArrayList<note>(); //stores notes in game
ArrayList<song> songsList = new ArrayList<song>();  //stores songs objects
boolean held = false; //used to make sure mouseclicked commands dont repeat
ArrayList<File> songsDir = new ArrayList<File>();//stores folder files for directory
ArrayList<button> GUI = new ArrayList<button>();//stores the buttons
boolean[] keys =  new boolean[4];//holds the keys
slist GUIlist;
boolean scrolling;
void setup(){
  logFile = createWriter(sketchPath() + "/logs/Log " + str(day()) + " " + str(month()) + " " + str(year()) + ".log");
  size(750, 900);
  cursor = 0;
  state = 0;
  loadMainGUI();  //loads main menu GUI
  loadSongDirectories();  //loads the song directories from the bMapDir.list file
  scrolling = false;
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
  boolean changes = false;  //checks for any changes in file system that are relevant to paths already imported
  if ((new File(sketchPath("bMapDir.list")).exists())){ //checks if bMap list exists
    for (String item : loadStrings("bMapDir.list")){
      File directory = new File(item);  //create File object to check for directory
      if (directory.exists()){ //if directory exits
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
  loadSongs();  //loads the song objects
}

void loadMainGUI(){ //creates GUI objects needed for the main screen
  GUI.clear();
  GUI.add(new button(width - 100, height - 70, "import"));
  GUI.add(new button(width - 100, height - 200, "play"));
  GUIlist = new slist();
}

void loadPlayGUI(){ //creates GUI objects needed for play screen
  GUI.clear();
}

void folderSelected(File selected){ //used for importing 
  if (selected != null){  //if something went wrong with the import, it wont run
    boolean duplicates = false;
    for (File item : songsDir){
      if (item.getAbsolutePath().equals(selected.getAbsolutePath())) duplicates = true;
    }
    if (!duplicates){  //checks for path duplicates
      songsDir.add(selected);
      saveSongDirectories();
      logs.append("Added Directory: " + selected.getAbsolutePath());
      logs.append("Refreshing song list");
      loadSongs();
    } else if (duplicates){
      logs.append("File: " + selected.getAbsolutePath() + " was already included in directory list");
    }
  } else logs.append("Import cancelled");
}

void loadSongs(){  //loads songs in songs array
  songsList.clear();
  for (File item : songsDir){
    for (File it2 : item.listFiles()){
      String fileExt = "";
      String path = it2.getName();
      for (int itemChar = path.length() - 1; path.charAt(itemChar) != '.'; itemChar--){
        fileExt += str(path.charAt(itemChar));  //checks for the extension of the file
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
  switch (state){  //switch game state
    case 0:  //main menu
    textSize(40);
    textAlign(CENTER);
    fill(255);
    text("COMPSCI 1C RHYTHM BEAT", width/2, 50);
    GUIlist.display();
    GUIlist.selection();
    break;
    case 1:  //game
    for(note item : notes){
      item.move();
      item.art();
    }
    break;
  }
  for(button item : GUI){  //this will spawn the gui buttons
    item.hover();
    switch(item.pressed()){
      case "import":
      selectFolder("Select folder containing beatmaps to import", "folderSelected");
      break;
      case "play":
      logs.append("Starting game");
      break;
      case "back":
      logs.append("Heading back to main menu");
      loadMainGUI();
      state = 0;
      break;
    }
    item.art();
  }
  if(logs.size() > 0){  // if something is in the log print it
    logProcess(logs.array());
    logs.clear();
  }
  if (!mousePressed && (held || scrolling)){  //used to check if a button is being pressed, but it won't activate multiple times.  Whereas it needs to be different with the scroll bar
    held = false;
    scrolling = false;
  }
}
class slist{
  //the start yPos for the mouse movement
  int mouseStr;
  //How many items were scrolled down
  int scroll;
  //what item was pressed
  int pressed;
  //Where the scroll bar shows up on the gui
  int scrollDisplay;
  //used for math /w scroll bar
  int origin;
  slist(){
    scroll = 0;
    pressed = -1;
    scrollDisplay = 0;
  }
  void display(){
    rectMode(CORNER);
    fill(50);
    rect(510, 190, 40, 540);
    if (songsList.size() > 0){ //displays scrollbar
      fill(230);
      if (songsList.size() > 10){  //displays a mobile scrollbar
        rect(510,scrollDisplay +  190, 40, (10/float(songsList.size())) * 540);
      } else {
        rect(510, 190, 40, 540);
      }
    }
    fill(0);
    rect(30, 150, 480, 620);
    if (songsList.size() <= 10){ //displays buttons that aren't active
      fill(50);
      rect(510, 150, 40, 40);
      rect(510, 730, 40, 40);
      fill(200);
      triangle(510, 150, 550, 150, 530, 190);
      triangle(510, 770, 550, 770, 530, 730);
    } else {  //displays active scroll buttons
      fill(230);
      rect(510, 150, 40, 40);
      rect(510, 730, 40, 40);
      fill(150);
      triangle(510, 150, 550, 150, 530, 190);
      triangle(510, 770, 550, 770, 530, 730);
    }  //displays the pressed graphic if a list item on screen was pressed
    if (pressed - scroll >= 0 && pressed - scroll < 10  && pressed < songsList.size()){
      fill(200);
      rect(30, 150 + (62 * (pressed - scroll)), 480, 63);
    }
    if (songsList.size() > 0){  //displays song names
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
    if (songsList.size() > 10){  //will only run if the songsList is bigger than what the list can hold
      if (mousePressed && !held && abs(mouseX - 530) <= 20 && abs(mouseY - 460) <= 270 && !scrolling){  //this initializes the scroll
        scrolling = true;
        mouseStr = mouseY;
        origin = scrollDisplay;
      } else if (scrolling){  //this actually runs the scroll
       scrollDisplay = origin + (mouseY - mouseStr);
       if (scrollDisplay < 0) scrollDisplay = 0;  //checks if scrollDisplay is higher/lower than it should be and prevents it
       else if (scrollDisplay + (10/float(songsList.size())) * 540 > 540) scrollDisplay = 540 - int((10/float(songsList.size())) * 540);
       //could have done this in 1 step, but for readability i did it in two
       float math = 540 - ((10/float(songsList.size())) * 540);
       scroll = int((scrollDisplay/math) * (songsList.size() - 10));
      }
    }if(mousePressed && !held && !scrolling && abs(mouseX - 300) <= 270 && abs(mouseY - 460) <= 310){  //this is for list selection and button scrolling
      held = true;
      if(songsList.size() > 10){  //buttons only work if more items in list than can be displayed at once
        if (abs(mouseX - 530) <= 20 && abs(mouseY - 170) <= 20){
          if(scroll + 10 < songsList.size()) scroll++;
        } else if (abs(mouseX - 530) <= 20 && abs(mouseY - 750) <= 20){
          if(scroll > 0) scroll--;
        }
      }  //list selection
      if (abs(270 - mouseX) <= 240 && abs(460 - mouseY)<= 310){
       pressed = scroll + int((mouseY - 150)/62);
      }
    }
  }
}
class button{
  color cProp;  //color of the button
  int x;  //unlike the scrollbar, the buttons wont all be in the same place
  int y;  //so when initialized they need to be told where to be put
  String title;  //what the button says, and what it returns when pressed
  button(int xA, int yA, String text){
    x = xA;
    y = yA;
    title = text;
    cProp = color(0, 0, 200);
  }
  void art(){
    //displays the button
    fill(cProp);
    rectMode(CENTER);
    rect(x, y, 150, 70);
    fill(255);
    textSize(20);
    text(title, x, y);
  }
  void hover(){
    //changes the color of the button if the mouse is hovering over it
    if (abs(mouseX - x) <= 75 && abs(mouseY - y) <= 35 && !held && !scrolling) cProp = color(0, 0, 150);
    else cProp = color(0, 0, 200);
  }
  String pressed(){  //check if it has been pressed
    if (mousePressed && abs(mouseX - x) <= 75 && abs(mouseY - y) <= 35 && !scrolling) cProp = color(100, 100, 255);  //well show that the button is being pressed
    //minor bug, if you keep the button held and move over another button, that other button will show being pressed, but it wont do anything.
    //I won't fix it, it is kinda fun to play with, although when every button has a function i don't think it will be easy to do it anymore.
    if (mousePressed && !held && !scrolling && abs(mouseX - x) <= 75 && abs(mouseY - y) <= 35){
      //this will trigger the action, and make sure the button won't activate anything else
      held = true;
      return title;
    } else return "false";
  }
}
StringDict parseMeta(String path){  //parse through the metadata of the songs
  String[] loadedmap = loadStrings(path);
  return null;
}
class song{ //stores song properties
  StringDict properties;
  song(String path){
  properties = new StringDict();
 // properties = parseMeta(path);
  if (properties == null){
    logs.append("<WARNING> Metadata for song was not loaded correctly");
  }
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

class note{  //stores each notes properties
  //what column it is on
  int column;
  //where it is on the board
  int y;
  //if it was successfully hit
  boolean success;
  //if it is a held note
  int held;
  note(int where, int time, int stop){
    y = time;
    column = where;
    held = stop;
    success = false;
  }
  void move(){
    //moves the note down
    y--;
  }
  void art(){
    //draws the note
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
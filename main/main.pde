// video playing stuff //<>//
import processing.video.*;

// music playng stuff
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
int timePause;  //used for a pause timer
boolean isPaused;  //used to tell fit the game was manually paused.
boolean autoPilot;  //used to check if the autoPilot is running
auto autoP;
String[] data;
//0: Total notes, 1: Notes that were hit, 2: Presses that missed a note
boolean stored;  //used to tell if the data array has been filled
int badHits;  //how many hits where there was no notes in the field
IntDict critContain; //this will store notes that are in the critical zone, and what column they are in
int state; //game state
StringList logs = new StringList();
PrintWriter logFile;  //This object is used for logging
ArrayList<note> notes = new ArrayList<note>(); //stores notes in game
ArrayList<song> songsList = new ArrayList<song>();  //stores songs objects
boolean held = false; //used to make sure mouseclicked commands dont repeat
ArrayList<File> songsDir = new ArrayList<File>();//stores folder files for directory
ArrayList<button> GUI = new ArrayList<button>();//stores the buttons
keyObj[] keys =  new keyObj[4];//holds the keys
slist GUIlist;  //this object is used for selecting the song
int changeState;  //used to change states
boolean scrolling;
// logo image
PImage logo;
// image background
PImage background;
// video background
Movie backgroundv;
// audio stuff
Minim minim;
AudioPlayer currentSong;

String scoreFind() {  //this determines the score and returns a message with it, the message changes based on your score.
  String returnVal = str(float(data[1]) / float(data[0]) * 10000);
  returnVal = str(int(returnVal) - (int(data[2]) * 10));
  if (int(returnVal) < 0) return "Wow, you really suck at this game....   You got " + returnVal;  //if you got a negative score....
  else if (int(float(data[1]) / float(data[0])) == 1 && int(data[2]) == 0) return "PERFECT GAME!";  //returns if it was a perfect game
  else return "You got " + returnVal;  //returns if regular score though
}
void setup() {
  timePause = -1;
  isPaused = false;
  autoP = new auto();
  for (int item = 0; item < keys.length; item++) {
    keys[item] = new keyObj(item);//inits keyObj array
  }
  stored = false;
  badHits = 0;
  logFile = createWriter(sketchPath() + "/logs/Log " + str(day()) + " " + str(month()) + " " + str(year()) + ".log");
  size(750, 900);
  state = 0;  //starting state
  loadSongDirectories();  //loads the song directories from the bMapDir.list file
  loadMainGUI();  //loads main menu GUI
  minim = new Minim(this);  // init audio framework
  changeState = -1;  //put change state into a state where it cant do anything
  scrolling = false;  //used for the scrolling bar
  //it is to make sure that the scroll bar scrolls, but nothing else is being pressed.
  logo = loadImage("assets/logo.png"); // load logo image
  logo.resize(1920/7, 891/7); // resize logo image
  critContain = new IntDict();
}

void initGame() {  //this initiates the game
  spawnNotes(); //spawns the notes for the song
  loadPlayGUI();  //loads the play button
}
void spawnNotes() {
  int rounds = 0;  //used for giving the notes an ID
  for (String item : loadStrings(songsList.get(GUIlist.returnItem()).returnPath())) {  //parses through each line
    rounds++;
    String result = "";  //these variables are needed to parse through the stuff, this variable stores the current data
    int count = 0;  //this tells what variable to write to
    //these store the data within the line
    int column = -1;  
    int time = -1;
    int held = -1;
    try {  //if one of the numbers has something other than a number in it, this statement will catch error so it doesn't crash the game.
      for (int i2 = 0; i2 < item.length(); i2++) {  //this parses through the line
        if (item.charAt(i2) != ',') {  //
          result+= item.charAt(i2);
        } else {
          if (count == 0) {  //stores to each variable, changes which one it changes to
            column = int(result);
          } else if (count == 1) time = int(result);
          result = "";
          count++;
        }
      }
      if (count == 2) {  //stores to the last variable, if it was formatted correctly.
        held = int(result);
        if (held == -1) notes.add(new note(column, time * -1, str(rounds)));
        else notes.add(new heldNote(column, time * -1, str(rounds), held));
      } else {  //this is also another way to check if the line wasn't formatted correctly
        logs.append("Error loading note " + str(rounds));
        rounds--;
      }
    } 
    catch (NumberFormatException e) {
      logs.append("Error loading note " + str(rounds));
      rounds--;
    }
  }
  logs.append("Loaded " + str(rounds) + " notes");
}

void saveSongDirectories() {
  //Loads the song directories from a file
  StringList store = new StringList();
  for (File item : songsDir) {
    store.append(item.getAbsolutePath());
    logs.append("Adding directory: " + item.getAbsolutePath() + " to directory list");
  }  //stores the directories in a file so the player doesnt have to look for it again
  saveStrings("bMapDir.list", store.array());
}

void loadSongDirectories() { //loads through beatmap file, first checks if it exists
  boolean changes = false;  //checks for any changes in file system that are relevant to paths already imported
  if ((new File(sketchPath("bMapDir.list")).exists())) { //checks if bMap list exists
    for (String item : loadStrings("bMapDir.list")) {
      File directory = new File(item);  //create File object to check for directory
      if (directory.exists()) { //if directory exits
        songsDir.add(directory);
        logs.append("Adding directory on path: " + item + " to list");
      } else {
        changes = true;
        logs.append("Song directory " + item + " does not exist");
      }
    }
    if (changes) {  //re writes song directores if there are changes
      logs.append("Re-writing song directory list, files listed have been altered");
      saveSongDirectories();
    }
  } else {
    createWriter("bMapDir.list");  //creates the file
    logs.append("bMapDir.list not found, creating file");
  }
  loadSongs();  //loads the song objects
}

void loadMainGUI() { //creates GUI objects needed for the main screen
  GUI.clear();
  GUI.add(new button(width - 100, height - 70, "import"));
  GUI.add(new button(width - 100, height - 200, "play"));
  GUI.add(new button(width - 100, height - 330, "auto pilot"));
  GUIlist = new slist();
}

void loadPlayGUI() { //creates GUI objects needed for play screen
  GUI.clear();
  GUI.add(new button(width - 100, height - 70, "back"));
  GUI.add(new button(width - 100, height - 200, "play/pause"));
}

void folderSelected(File selected) { //used for importing 
  if (selected != null) {  //if something went wrong with the import, it wont run
    boolean duplicates = false;
    for (File item : songsDir) {
      if (item.getAbsolutePath().equals(selected.getAbsolutePath())) duplicates = true;
    }
    if (!duplicates) {  //checks for path duplicates
      songsDir.add(selected);
      saveSongDirectories();
      logs.append("Added Directory: " + selected.getAbsolutePath());
      logs.append("Refreshing song list");
      loadSongs();
    } else {  //won't save if there is a duplicate
      logs.append("File: " + selected.getAbsolutePath() + " was already included in directory list");
    }
  } else logs.append("Import cancelled");
}

void loadSongs() {  //loads songs in songs array
  songsList.clear();  //clears the songsList, this prevents duplicates
  for (File item : songsDir) {
    for (File it2 : item.listFiles()) {
      String fileExt = "";
      String path = it2.getName();
      for (int itemChar = path.length() - 1; path.charAt(itemChar) != '.'; itemChar--) {
        fileExt += str(path.charAt(itemChar));  //checks for the extension of the file
        if (fileExt.equals("paMb")) {  //The way im inputing to the string makes it backwards....  Whoops
          songsList.add(new song(it2.getAbsolutePath()));
          logs.append("LOADED BEATMAP: " + path);
        } 
        if (itemChar - 1< 0) break; //this will make sure the that the program doesnt extend past the length of the string
      }
    }
  }
}

void draw() {
  background(90, 0, 90);
  switch (state) {  //switch game state
  case 0:  //main menu
    textSize(40);
    textAlign(CENTER);
    fill(255);
    image(logo, 240, 15);
    GUIlist.display();
    GUIlist.selection();
    break;
  case 1:  //game
    // set line weight and color
    if (currentSong.isPlaying() || isPaused || timePause != -1) {

      // draw background
      background(background);
      // fix rectangles
      rectMode(CORNER);
      // draw translucent backdrop
      fill(0, 0, 0, 191); // 75% opacity
      rect(0, 0, 500, 900);
      // draw critical zone
      fill(255, 132, 0);
      rect(0, 800, 500, 100);
      rectMode(CENTER);
      // draw note separation lines
      strokeWeight(16);
      stroke(255);
      line(0, 0, 0, 900);
      line(125, 0, 125, 900);
      line(250, 0, 250, 900);
      line(375, 0, 375, 900);
      line(500, 0, 500, 900);
      strokeWeight(1);
      stroke(0);
      if (isPaused) {  //changes the screen the color of the screen except the buttons if it is paused
        fill(0, 171);
        strokeWeight(0);
        rect(0, 0, width * 2, height * 2);  //This for some reason dealing with the width and height only returns half of the width and height
        strokeWeight(1);
        textSize(100);
        fill(255);
        text("PAUSED", width/2, 100);
      } else if (millis() - timePause < 3000 && timePause != -1) {  //pause screen
        fill(0, 171);
        strokeWeight(0);
        rect(0, 0, width * 2, height * 2);  //This for some reason dealing with the width and height only returns half of the width and height
        strokeWeight(1);
        textSize(100);
        fill(255);
        textSize(100);
        text(str(int((3000 - (millis() - timePause))/1000)), width/2, height/2);
      } else if (millis() - timePause > 3000) {  //countdown to start
        timePause = -1; 
        currentSong.play();
        backgroundv.play();
      }
      //animate notes
      //will only work if it isn't paused
      if (currentSong.isPlaying() || timePause != -1) {  //left the note artwork out if is drawn on purpose, then people can't cheat
        if (millis() - timePause > 3000 && autoPilot) autoP.run();  //runs autopilot
        int cursor = currentSong.position();
        for (note item : notes) {
          item.art(cursor);
          if (timePause == -1 ) item.hitDetect(cursor);
        }
      }
    } else if (stored && !isPaused) {  //this will happen if the end game data has been stored.
      background(0);
      fill(255);
      textSize(20);
      text("Empty hits: " + data[2] + " x -10", width/2, 50);
      text("Successful Notes (" + data[1] + ") / total notes (" + data[0] + ") x 10000", width/2, 25);
      textSize(20);
      text("RESULT: \n" + data[3], width/2, 100);
    } else if (!isPaused) {//this will store the data in the data array
      GUI.remove(1);
      data[0] = str(notes.size());  //how many notes were there
      int good = 0;
      for (note item : notes) {
        if (item.success) good++;
      }
      data[1] = str(good);  //Notes that were hit
      data[3] = scoreFind();  //score
      stored = true;
    }
    break;
  }
  for (button item : GUI) {  //this will animate the gui buttons, and is used for if it is pressed
    item.hover();  //checks if the mouse is hovering over the button
    switch(item.pressed()) {  //this will tell if a button was pressed 
    case "import":
      //this ends imports files
      selectFolder("Select folder containing beatmaps to import", "folderSelected");
      break;
    case "play/pause":
      //this pauses the game and the song
      if (currentSong.isPlaying()) {
        backgroundv.pause();
        currentSong.pause();
      } else {
        timePause = millis();
      }
      isPaused = !isPaused;
      break;
    case "auto pilot":
      //this will run autopilot mode
      autoPilot = true;
    case "play":
      //this checks if there is a VALID file selected, and if there isnt one, it will start the game
      if (GUIlist.returnItem() > -1) {
        logs.append("Initiating game");
        changeState = 1;  //Changes the state to play the game
      } else {
        if (autoPilot) {
          autoPilot = false;
        }
        logs.append("Error with file selected, not starting game");
      }
      break;
    case "back":
      //heads back to the main menu
      logs.append("Heading back to main menu");
      changeState = 0;
      autoPilot = false;
      isPaused = false;
      break;
    }
    item.art();  //this draws the button
  }
  if (changeState == 1) {
    //this starts the game
    initGame();
    currentSong = minim.loadFile(songsList.get(GUIlist.returnItem()).returnPath().replace("map.bMap", songsList.get(GUIlist.returnItem()).returnAudio()));
    if (new File(songsList.get(GUIlist.returnItem()).returnPath().replace("map.bMap", "backgroundv.avi")).exists()) { // check for background image
      backgroundv = new Movie(this, songsList.get(GUIlist.returnItem()).returnPath().replace("map.bMap", "backgroundv.avi"));
      backgroundv.play();
      background = backgroundv;
    } else if (new File(songsList.get(GUIlist.returnItem()).returnPath().replace("map.bMap", "background.jpg")).exists()) { // check for background image
      background = loadImage(songsList.get(GUIlist.returnItem()).returnPath().replace("map.bMap", "background.jpg"));
      background.resize(width, height);
    }
    data = new String[4];  //inits the data array
    for (int item = 0; item < data.length; item++) {
      data[item] = "0";
    }
    timePause = -1;
    stored = false;
    state = 1;
    changeState = -1;
    currentSong.play();
  } else if (changeState == 0) {
    //this goes back to the main menu
    if (currentSong.isPlaying()) {
      currentSong.pause();
      currentSong.close();
    }
    state = 0;
    loadMainGUI();  //loads the main menu GUI
    changeState = -1;
    notes.clear();
  }
  if (logs.size() > 0) {  // if something is in the log print it
    logProcess(logs.array());
    logs.clear();
  }
  if (!mousePressed && (held || scrolling)) {  //used to check if a button is being pressed, but it won't activate multiple times.  Whereas it needs to be different with the scroll bar
    held = false;
    scrolling = false;
  }
}
class slist {
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
  slist() {
    scroll = 0;
    pressed = -1;
    scrollDisplay = 0;
  }
  void display() {
    rectMode(CORNER);
    fill(50);
    rect(510, 190, 40, 540);
    if (songsList.size() > 0) { //displays scrollbar
      fill(230);
      if (songsList.size() > 10) {  //displays a mobile scrollbar
        rect(510, scrollDisplay +  190, 40, (10/float(songsList.size())) * 540);
      } else {
        rect(510, 190, 40, 540);
      }
    }
    fill(0);
    rect(30, 150, 480, 620);
    if (songsList.size() <= 10) { //displays buttons that aren't active
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
    if (pressed - scroll >= 0 && pressed - scroll < 10  && pressed < songsList.size()) {
      fill(200);
      rect(30, 150 + (62 * (pressed - scroll)), 480, 63);
    }
    if (songsList.size() > 0) {  //displays song names
      for (int item = scroll; item < scroll + 10; item++) {
        if (item >= songsList.size()) break;  //in case the song list is smaller than ten, it will break the for loop
        song display = songsList.get(item);
        textAlign(LEFT, TOP);
        textSize(17);
        if (display.returnError()) {  //this will display if the song is corrupt
          fill(255, 0, 0);
          text("CORRUPT FILE", 30, 170 + (62 * (item - scroll)));
        } else fill(255);
        text(display.returnName(), 30, 150 + (62 * (item - scroll)));
        textAlign(CENTER);
      }
    }
  }
  void selection() {
    if (songsList.size() > 10) {  //will only run if the songsList is bigger than what the list can hold
      if (mousePressed && !held && abs(mouseX - 530) <= 20 && abs(mouseY - 460) <= 270 && !scrolling) {  //this initializes the scroll
        scrolling = true;
        mouseStr = mouseY;
        origin = scrollDisplay;
      } else if (scrolling) {  //this actually runs the scroll
        scrollDisplay = origin + (mouseY - mouseStr);
        if (scrollDisplay < 0) scrollDisplay = 0;  //checks if scrollDisplay is higher/lower than it should be and prevents it
        else if (scrollDisplay + (10/float(songsList.size())) * 540 > 540) scrollDisplay = 540 - int((10/float(songsList.size())) * 540);
        //could have done this in 1 step, but for readability i did it in two
        float math = 540 - ((10/float(songsList.size())) * 540);
        scroll = int((scrollDisplay/math) * (songsList.size() - 10));
      }
    }
    if (mousePressed && !held && !scrolling && abs(mouseX - 300) <= 270 && abs(mouseY - 460) <= 310) {  //this is for list selection and button scrolling
      held = true;
      if (songsList.size() > 10) {  //buttons only work if more items in list than can be displayed at once
        if (abs(mouseX - 530) <= 20 && abs(mouseY - 170) <= 20) {
          if (scroll + 10 < songsList.size()) scroll++;
        } else if (abs(mouseX - 530) <= 20 && abs(mouseY - 750) <= 20) {
          if (scroll > 0) scroll--;
        }
      }  //list selection
      if (abs(270 - mouseX) <= 240 && abs(460 - mouseY)<= 310) {
        if (scroll + int((mouseY - 150)/62) < songsList.size())pressed = scroll + int((mouseY - 150)/62);
      }
    }
  }
  int returnItem() {  //returns the current item pressed
    if (pressed == -1 ||songsList.get(pressed).returnError()) return -1;  //this only works because I am using the logical OR statement
    //in other words, the songsList.get(pressed).returnError() won't run if pressed = -1.  Because the logical OR statement evaluates the first one, and if that is true, it won't evaluate the next thing.
    else return pressed;
  }
}
class button {
  color cProp;  //color of the button
  int x;  //unlike the scrollbar, the buttons wont all be in the same place
  int y;  //so when initialized they need to be told where to be put
  String title;  //what the button says, and what it returns when pressed
  button(int xA, int yA, String text) {
    x = xA;
    y = yA;
    title = text;
    cProp = color(0, 0, 200);
  }
  void art() {
    //displays the button
    fill(cProp);
    rectMode(CENTER);
    rect(x, y, 150, 70);
    fill(255);
    textSize(20);
    text(title, x, y);
  }
  void hover() {
    //changes the color of the button if the mouse is hovering over it
    if (abs(mouseX - x) <= 75 && abs(mouseY - y) <= 35 && !held && !scrolling) cProp = color(0, 0, 150);
    else cProp = color(0, 0, 200);
  }
  String pressed() {  //check if it has been pressed
    if (mousePressed && abs(mouseX - x) <= 75 && abs(mouseY - y) <= 35 && !scrolling) cProp = color(100, 100, 255);  //well show that the button is being pressed
    //minor bug, if you keep the button held and move over another button, that other button will show being pressed, but it wont do anything.
    //I won't fix it, it is kinda fun to play with.  And the bug isn't to noticable, and kinda hard to activate
    if (mousePressed && !held && !scrolling && abs(mouseX - x) <= 75 && abs(mouseY - y) <= 35) {
      //this will trigger the action, and make sure the button won't activate anything else
      held = true;
      return title;
    } else return "false";  //this won't do anything
  }
}
StringDict parseMeta(String path) {  //parse through the metadata of the songs
  JSONObject metadata;
  StringDict retV = new StringDict(); //Return value
  //retV.set("key", "info");
  if ((new File(path.replace("map.bMap", "meta.json"))).exists()) {
    retV.set("ERROR", "NULL");
    metadata = loadJSONObject(path.replace("map.bMap", "meta.json"));
    if (!(metadata.isNull("AudioFilename"))) {  //this will first check if something exists.  If it doesn't, returns an error and song wont be playable
      retV.set("AudioFilename", metadata.getString("AudioFilename"));
    } else retV.set("ERROR", "CORRUPT FILE");
    if (metadata.isNull("AudioLeadIn")) retV.set("ERROR", "CORRUPT FILE");
    else retV.set("AudioLeadIn", metadata.getString("AudioLeadIn"));
    if (metadata.isNull("Title")) retV.set("ERROR", "CORRUPT FILE");
    else retV.set("Title", metadata.getString("Title"));
    if (metadata.isNull("Title")) retV.set("ERROR", "CORRUPT FILE");
    else retV.set("TitleUnicode", metadata.getString("TitleUnicode"));
  } else {
    retV.set("ERROR", "meta.json not found");
  }
  return retV;
}
class song { //stores song properties
  StringDict properties;
  song(String path) {  //this gets the properties
    properties = new StringDict();
    properties = parseMeta(path);
    properties.set("path", path);
    if (!(properties.get("ERROR").equals("NULL"))) {
      //logs if there was an error
      logs.append("<WARNING> Metadata for song was not loaded correctly");
    } else {
      //checks if the audio file isn't there, if it is then it sets the class status to corrupt
      if (!(new File(properties.get("path").replace("map.bMap", properties.get("AudioFilename"))).exists())) { 
        properties.set("ERROR", "Audio file doesn't exist");
        logs.append("<WARNING> The audio file " + properties.get("AudioFilename") + " does not exist for " + properties.get("path"));
      }
    }
  }
  String returnPath() {
    return properties.get("path");
    //returns the path
  }
  boolean returnError() {
    //returns if it ran into an error parsing
    if (properties.get("ERROR").equals("NULL")) return false;
    else return true;
  }
  String returnName() {
    //returns the name of the song
    return properties.get("Title");
  }
  String returnAudio() {
    //returns the name of the audio file
    return properties.get("AudioFilename");
  }
}

class note {  //stores each notes properties
  //what column it is on
  int column;
  //where it is on the board
  int y;
  //if it was successfully hit
  boolean success;
  //used in checking if it is in the critical zone
  boolean inCrit;
  String ID;  //this will be used for dealing the the critContain dictionary
  note(int where, int time, String id) {  //initializes the note
    ID = id;
    y = time;
    column = where;
    success = false;
  }
  void art(int yOffset) {
    //draws the note
    strokeWeight(8);
    if (success) {
      stroke(0, 255, 0);
    } else if (inCrit) {
      stroke(0);
    } else {
      stroke(255);
    }
    line(column * 125, y + yOffset + 800, (column * 125) + 125, y + yOffset + 800);  //draws held notes
    stroke(0);
    strokeWeight(1);
  }
  void hitDetect(int yOffset) {
    if (y + yOffset > 0 && y + yOffset < 100) {
      if (!success) {  //need a nested if statement or hit detection and registering bad hits will get really screwy...
        if (!inCrit) {  //this will set the button to make sure it is in the critical zone, but it won't keep overwriting it
          inCrit = true;
          critContain.set(ID, column);
        }//checks for a success
        if (keys[column].value) {
          success = true;
        }
      }
    } else if (inCrit) { //makes sure it still doesn't think it is in the critical zone
      inCrit = false;
      critContain.remove(ID);
    }
  }
}

class heldNote extends note {  //HELD NOTES
  int heldTo;
  int keyHeld;
  heldNote(int where, int time, String ID, int held) {//initializes the class
    super(where, time, ID);
    heldTo = held * -1;
    keyHeld = -1;
  }
  void art(int yOffset) {  //draws the note
    strokeWeight(3);
    rectMode(CORNER);
    if (!inCrit)stroke(255);
    else stroke(0);
    if (keyHeld != -1) fill(0, 0, 255);  //so not every note is blue
    else fill(255, 132, 0);
    rect(column * 125, 800 + y + yOffset, 125, heldTo - y);
    stroke(0);
    rectMode(CENTER);
    strokeWeight(1);
  }
  void hitDetect(int yOffset) {  //hit detection is different for these notes
    if (y + yOffset > 0 && heldTo + yOffset < 100) {
      if (!success) {  //need a nested if statement or hit detection and registering bad hits will get really screwy...
        if (!inCrit) {//this will set the button to make sure it is in the critical zone, but it won't keep overwriting it
          inCrit = true;
          critContain.set(ID, column);
        }
        if (keys[column].value && keyHeld == -1) {//start of the note being "held"
          keyHeld = currentSong.position();
        } else if (keyHeld != -1 && !keys[column].value) {  //this is to check if the note is a success after the player let go of it
          if ((float((currentSong.position()) - keyHeld) / float((heldTo * -1) + y)) > 0.85) {
            success = true;
          }
          keyHeld = -1;
        }
      }
    } else if (inCrit) {
      inCrit = false;
      critContain.remove(ID);
      if (keyHeld != -1) {  //this will also check to see if the note was a success
        if ((float((heldTo * -1) - keyHeld) / float((heldTo * -1) + y)) > 0.85) {
          success = true;
        }
        keyHeld = -1;
      }
    }
  }
}

void logProcess(String[] output) { //prints out logs to a file every loop
  for (String item : output) {
    logFile.println("[" + str(hour()) + ":" + str(minute()) + ":" + str(second()) + "]: " + item);
    println(item);  //i also want it to print to the console
  }
}

class keyObj {  //this is for registering key hits
  int timer;
  boolean value;
  private int ID;  //private because I don't want to screw it up
  keyObj(int item) {
    timer = -1;
    value = false;
    ID = item;
  }
  void requestOn() {  //turns value on
    if (millis() - timer > 100) { //makes sure there is a time penalty if the hit is a miss
      if (checkIfNotes()) {
        value = true;
      } else {
        data[2] = str(int(data[2]) + 1);  //adds to the missed hits score
        timer = millis();  //re-inits the timer
      }
    }
  }
  boolean checkIfNotes() {  //checks if the there needs to be a penalty for a missed note
    for (int item : critContain.values()) {  //if there is a note in the critical zone, it is good
      if (item == ID) return true;
    }
    return false;
  }
}

void keyPressed() {
  //checks for held presses
  if (!autoPilot && state == 1 && currentSong.isPlaying()) {  //will only work if autopilot is off, and the game is running
    if (key == 'a') {
      keys[0].requestOn();
    } else if (key == 's') {
      keys[1].requestOn();
    } else if (key == 'l') {
      keys[2].requestOn();
    } else if (key == ';') {
      keys[3].requestOn();
    }
  }
}

class auto {//plays the game perfectly
  void run() {
    for (int item : critContain.values()) {
      if (!keys[item].value) {
        keys[item].requestOn();
      }
    }
  }
}

void keyReleased() {
  //tells when the key is no longer being held
  if (key == 'a') {
    keys[0].value = false;
  } else if (key == 's') {
    keys[1].value = false;
  } else if (key == 'l') {
    keys[2].value = false;
  } else if (key == ';') {
    keys[3].value = false;
  }
}

void movieEvent(Movie m) {
  m.read();
}
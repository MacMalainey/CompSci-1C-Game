import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

// CONFIGURATION STUFF
// SET THE SONG TO LOAD AND THE BPM OF THE SONG HERE
int bpm = 140;
String loadSong = "test.mp3";
// END CONFIGURATION
// DON'T TOUCH ANYTHING BELOW THIS LINE

// make the arraylist
ArrayList<String[]> notes = new ArrayList<String[]>();
// make the array
// format is {isitaslider, isitaheldnote, column, position, {slider_column_start, slider_start, slider_column_end, slider_end}, {held_start, held_end}}
//                                                          These are only used if the note is a slider or held note, otherwise all values are ignored
int[] temparray = new int[4];

Minim minim;
AudioPlayer song;

// check for pressed keys
// pattern is UP, DOWN, LEFT, RIGHT, SHIFT
boolean[] keys = {
  false, false, false, false, false
};

int songLength;
int cursorPos;
int milliPos;

void setup() {
  size(900, 1280);
  background(0);
  minim = new Minim(this);
  song = minim.loadFile(loadSong);
  
  songLength = song.length();
}

void draw() {
  clear(); // clear the framebuffer
  
  // check for keypresses, handle as needed
  // basic movement keys
  if (keys[0]) milliPos--;
  if (keys[1]) milliPos++;
  // movement modifier keys
  if (keys[0] && keys[4]) milliPos = milliPos - 10;
  if (keys[1] && keys[4]) milliPos = milliPos + 10;
  
  // draw note lines
  stroke(255);
  strokeWeight(5);
  line(144, 0, 144, 1280);
  line(288, 0, 288, 1280);
  line(432, 0, 432, 1280);
  // draw critical line
  strokeWeight(8);
  stroke(255, 162, 0);
  line(0, 1200, 576, 1200);
  // draw information line
  stroke(255);
  strokeWeight(10);
  line(576, 0, 576, 1280);
  // draw second information line
  line(700, 0, 700, 1280);
  // prevent cursor from leaving playing field
  if (cursorPos < 0) cursorPos = 0;
  if (cursorPos > 3) cursorPos = 3;
  // draw cursor
  stroke(0, 0, 255);
  line(cursorPos*144, milliPos, cursorPos*144+144, milliPos);
  
  // draw millisecond markers
  textSize(16);
  text("0", 600, 1200);
  
  textSize(16);
  text(int(frameRate), 720, 20);  // draw frame rate
  text(songLength, 720, 40);
  text(song.position() + "/" + songLength, 720, 80);
}

void keyPressed() {
  if (keyCode == UP) keys[0] = true;
  if (keyCode == DOWN) keys[1] = true;
  if (keyCode == LEFT){keys[2] = true; cursorPos--;}
  if (keyCode == RIGHT){keys[3] = true; cursorPos++;}
  if (keyCode == SHIFT) keys[4] = true;
  
  if (key == ' ') {
    if (song.isPlaying()) song.pause();
    else song.play();
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) keys[0] = false;
    if (keyCode == DOWN) keys[1] = false;
    if (keyCode == LEFT) keys[2] = false;
    if (keyCode == RIGHT) keys[3] = false;
    if (keyCode == SHIFT) keys[4] = false;
  }
}

void addNote() {
  
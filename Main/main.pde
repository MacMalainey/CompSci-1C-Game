int cursor;  //yOffset
int state;

void setup(){
  cursor = 0;
  state = 0;
}

void draw(){
  switch (state){
    case 0: //main menu
    break;
  }
}

class note{
  int column;
  int y;
  note(int time){
    y = time;
  }
  void move(){
    y--;
  }
  void art(){
    
  }
}
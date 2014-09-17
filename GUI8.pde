import processing.serial.*;
import g4p_controls.*;

Serial myPort;

//Logging timing parameters defaults
int logInterval = 10;
int launchDay = day();
int launchHour = hour();
int launchMin = minute();
int launchPortIndex = 1;
int secMinHourIndex = 0;
String logFileName = "FileName";
String secMinHour[] = {"sec","min","hour"};

//Gui working variables
boolean errorFlag = false;
boolean launchFlag = false;
int logIntervalSend = 0;
int launchDaySend = 0;
int launchHourSend = 0;
int launchMinSend = 0;
int launchPortIndexSend = 0;
String logFileNameSend = "log";
String messageLn1 = "Select launch time & day of the month, logging interval, and logger";
String messageLn2 = "com port using sliders and drop menu.  Click launch when finished.";
String textFieldMessage = "";
boolean displayMessageFlag = true;
boolean dotDotFlag = false;
boolean doneFlag = false;
String dotsStr = ".";
int dotsInt = 0;
int mil = millis();
int lastMillis = 0;

//Get time working variables
boolean secondsOver60=false, minutesOver60=false;
String incoming = "";
String printthis = "";
char gettimecommand = 'G';
boolean Newthing = false;
int s = second();
int m = minute();
int h = hour();
int d = day();
int mo = month();
int y = year();
int inByte = 0;
char inByteChar = 'Z';

void serialEvent(Serial myPort){ //handler for all serial communication with microcontroller
  
  inByte = myPort.read();
  
  if(inByte == 71){
    inByte = myPort.read();
    if(inByte == 84){
      messageLn1 = "Sending Time";
      messageLn2 = "";
      s = second() + 1;  // sends what the time will be after 2 seconds
      if(s>=60){
         s = s - 60;
      }
      m = minute();
      h = hour();
      if(minutesOver60==true){
        h++;
        minutesOver60=false;
      }
      if(h>=24){
        h = h - 24;
      }
      d = day();
      mo = month();
      y = year() - 2000;
      myPort.write(m + "," + h + "," + 1 + "," + d + "," + mo + "," + y + "," + s + '\n');
      byte GO = 127;
      while(second() != s){}
      myPort.write(GO);
      }
  } else if(inByte == 'C'){
     inByte = myPort.read();
     if(inByte == 'T'){
      messageLn1 = "Confirming Time";
      String incoming = myPort.readStringUntil('\n');
      incoming = incoming.substring(0, incoming.length() -1);
      s = second();
      m = minute();
      h = hour();
      d = day();
      mo = month();
      y = year();
      messageLn2 = "RTC Time: " + incoming + "    PC Time: " + mo + "/" + d + "/" + y + " " + h + ":" + m + ":" + s;      
    }
  } else if(inByte == 'L'){
     inByte = myPort.read();
     if(inByte == 'P'){
      messageLn1 = "Sending Launch Parameters";
      messageLn2 = "";
      myPort.write(logIntervalSend + "," + launchDaySend + "," + launchHourSend + "," + launchMinSend);
      myPort.write(logFileNameSend + '\n');
     }
  } else if(inByte == 'P'){
    inByte = myPort.read();
    if(inByte == 'C'){
     messageLn1 = "Confirming Launch Parameters";
     String incoming = myPort.readStringUntil('\n');
     incoming = incoming.substring(0, incoming.length() -1);
     String[] list = split(incoming, ',');
     messageLn2 ="Launch Day: " + list[0] + " Launch Hour: " + list[1] + " Launch Minute: " + list[2];
     delay(1000);
     dotDotFlag = false;
     doneFlag = true;
     messageLn1 = "Done. Please close this window.";
     messageLn2 = "";
    }
  }
  myPort.clear();
}
//**************************

public void displayMessage(){
  text(messageLn1, 30, 280);
  text(messageLn2, 30, 300);
}

//**************************

public void dotDotMessage(){
  mil = millis();
  if((mil - lastMillis) > 500){
    lastMillis = mil;
    if(dotsInt < 7){
    dotsStr = dotsStr + ".";
    dotsInt++;
    } else {
       dotsInt = 0;
       dotsStr = ".";
    }
  }
  text(messageLn1 + dotsStr, 30, 280);
  text(messageLn2, 30, 300);
}

//**************************

public void launch(){
  launchFlag = true;
  switch(secMinHourIndex){
    case 0:
      logIntervalSend = logInterval;
      break;
    case 1:
      logIntervalSend = logInterval*60;
      break;
    case 2:
      logIntervalSend = logInterval*60*60;
      break;
  }
  println(logIntervalSend);
  launchDaySend = launchDay;
  launchHourSend = launchHour;
  launchMinSend = launchMin;
  launchPortIndexSend = launchPortIndex;
  logFileNameSend = logFileName + ".csv";
  
  dotDotFlag = true;
  myPort = new Serial(this, Serial.list()[launchPortIndexSend], 19200);
  myPort.bufferUntil('\n');
}

//****************************************************************************
//****************************************************************************

public void setup(){
  size(480, 370, JAVA2D);
  textSize(12);
  createGUI();
  customGUI();
  // Place your setup code here
  
}

//**************************

public void draw(){
  background(230);
  fill(0,0,0);
  if(dotDotFlag){
    dotDotMessage();
  } else {
    displayMessage();
  }
  if(!launchFlag){
    fill(0,0,0);
    text(logInterval, 280, 39);
    text("(logging interval)", 310, 39);
    text(launchDay, 280, 79);
    text("(day of month to launch)", 310, 79);
    text(launchHour, 280, 119);
    text("(hour to launch)", 310, 119);
    text(launchMin, 280, 159);
    text("(minute to launch)", 310, 159);
    text("(selected serial port)", 310, 245);
    //print(logFileName.length());
    if((logFileName.indexOf(32)) != -1 && (logFileName.length() != 1)){
        fill(255,0,0);
        textFieldMessage = "Filename cannot contain spaces.";
        errorFlag = true;
      }
    
    else if(logFileName.charAt(0) >= 48 && logFileName.charAt(0) <=57){
      fill(255,0,0);
      textFieldMessage = "Filename cannot start with an integer.";
      errorFlag = true;
    }
    else if(logFileName.length() > 8){ 
      fill(255,0,0);
      textFieldMessage = "Your filename is too long.";
      errorFlag = true;
      
    }
    else {
      errorFlag = false;
      textFieldMessage = ".csv    Enter file name, limited to 8 characters";
    }
    text(textFieldMessage, 105, 200);
    
  }
  if(launchFlag){
    fill(120,120,120);
    text(logIntervalSend, 280, 39);
    text("(logging interval)", 310, 39);
    text(launchDaySend, 280, 79);
    text("(day of month to launch)", 310, 79);
    text(launchHourSend, 280, 119);
    text("(hour to launch)", 310, 119);
    text(launchMinSend, 280, 159);
    text("(minute to launch)", 310, 159);
    text("(selected serial port)", 310, 245);
    if(doneFlag == false) button1.setText(dotsStr + "Launching" + dotsStr);
    if(doneFlag == true) button1.setText("Launch Complete.");
    text(textFieldMessage, 105, 200);
    if(logFileName.length() > 7) textFieldMessage = ".csv     Your filename is too long";
    else textFieldMessage = ".csv     Enter file name, limited to 8 characters";
    button1.setTextBold();
  }
 
}

//**************************

// Use this method to add additional statements
// to customise the GUI controls
public void customGUI(){

}

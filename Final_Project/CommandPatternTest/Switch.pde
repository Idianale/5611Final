import java.util.HashMap;

// Command Interface
interface Command{
  void execute(); 
}

// Invoker Class
class tasks{
  private final HashMap<String, Command> commandMap = new HashMap(); 
  
  public void register(String commandName, Command command){
    commandMap.put(commandName, command); 
  }
  
  public void execute(String commandName){
    Command command = commandMap.get(commandName); 
    if(command == null){
      throw new IllegalStateException(" no command registered for " + commandName); 
    }
    command.execute(); 
  }
}


//---------- Commands For Light Switch ------------------------
//Conncrete Command #1
class SwitchOnCommand implements Command{
  private final Light light; 
  
  public SwitchOnCommand(Light light){
    this.light = light; 
  }
  
  @Override 
  public void execute(){
    light.turnOn(); 
  }
}

// Concrete Command #2
class SwitchOffCommand implements Command{
  private final Light light; 
  
  public SwitchOffCommand(Light light){
    this.light = light; 
  }
  
  @Override 
  public void execute(){
    light.turnOff(); 
  }
}

class SwitchWarningCommand implements Command{
  private final Light light; 
  public SwitchWarningCommand(Light light){
    this.light = light; 
  }
  
  @Override
  public void execute(){
    light.warning(); 
  }
  
}

//--------------------------------------------- 
//Light Object
class Light{
  PVector pos; 
  int status;
  
  
  Command switchOn;
  Command switchOff; 
  Command switchWarning; 
  tasks plan; 
  color myColor; 
  
  Light(){
    status = SAFE;
    pos = new PVector(100,100,0); 
    // Associate this command object to the light object
    switchOn = new SwitchOnCommand(this); 
    switchOff = new SwitchOffCommand(this); 
    switchWarning = new SwitchWarningCommand(this); 
    
    // Register to the task list
    plan = new tasks(); 
    plan.register("on", switchOn); 
    plan.register("off", switchOff); 
    plan.register("warning", switchWarning); 
    turnOn(); 
  }
  
  Light(float x, float y){
    status = DANGER;
    turnOff(); 
    pos = new PVector(x,y,0); 
    switchOn = new SwitchOnCommand(this); 
    switchOff = new SwitchOffCommand(this); 
    switchWarning = new SwitchWarningCommand(this); 
    
    plan = new tasks(); 
    plan.register("on", switchOn); 
    plan.register("off", switchOff); 
    plan.register("warning", switchWarning); 
  }
  
  public void turnOn(){
    myColor = #06CB14; 
    println("The Light is green"); 
  }
  public void turnOff(){
    myColor = #E50532; 
    println("The Light is red"); 
  }
  public void warning(){
    myColor = #FFF303; 
    println("The Light is yellow"); 
  }
  
  void display(){
    fill(myColor); 
    rect(pos.x,pos.y,100,100);
  }
  
  void lightSwitch(){
    switch (lamp.status){
      case SAFE:
        status = WARNING; 
        plan.execute("warning"); 
        break; 
      case WARNING:
        status = DANGER; 
        plan.execute("off"); 
        break; 
      case DANGER:
        status = SAFE; 
        plan.execute("on"); 
        break; 
      default:
        status = DANGER; 
        plan.execute("off"); 
        break;
    }
  }
  
  // Execute Plan 
  /*
  input: data structure holding list of all actions to execute in order; 
  for every, agent world state, 
  
  */
  
}

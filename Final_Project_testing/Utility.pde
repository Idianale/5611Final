// Need to implement functions as callable using the command design pattern

// AgentType
static final int AQUISITION = 0, RECON = 1, PREDATOR = 2; 

// ActionType
static final int IDLE = 0, NAVIGATE = 1,
                  COLLECT = 2, FLEE = 3, HUNT = 4,
                  PATROL = 5, PLAN = 6; 

// Safety Status
static final int SAFE = 0, WARNING = 1, DANGER = 2; 

class BlackBoard {
    ArrayList<Resource> resources;
    ArrayList<Agent> collective;
    PVector predLastSeen = new PVector();
    int status = 0;
}

BlackBoard blackboard; 

class State {
    int AgentType; 
    int ActionType;
    boolean PredatorInRange;
    boolean inCollective;
    boolean resourcesAvailable;

    State(int type) {
      switch(type){
        case AQUISITION:
          AgentType = type; 
          ActionType = 0; 
          PredatorInRange = false;      
          inCollective = true; 
          resourcesAvailable = true;
          break; 
        case RECON: 
          AgentType = type; 
          ActionType = 6; 
          PredatorInRange = false;      
          inCollective = true; 
          resourcesAvailable = true;
          break; 
        case PREDATOR:
          AgentType = type; 
          ActionType = 5; 
          PredatorInRange = false;      
          inCollective = false; 
          resourcesAvailable = true;
          break; 
      }

    }
}

interface Planner{
  //void checkWorldState(); 
  //void checkPlan(); 
  void generatePlan(); 
}

// temp
PVector predLastSeen = new PVector();

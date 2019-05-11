// Need to implement functions as callable using the command design pattern

static final int SAFE = 0, WARNING = 1, DANGER = 2; 

class BlackBoard {
    ArrayList<Resource> resources;
    ArrayList<Agent> collective;
    PVector predLastSeen;
    final int status = 0;
}

class State {
    boolean PredatorInRange;
    boolean isGathering;
    boolean isFleeing;
    boolean isHunting;
    boolean isNavigating;
    boolean inCollective;
    boolean resourcesAvailable;

    State() {
    }
}

// Need to implement functions as callable using the command design pattern

enum Status {
    SAFE, ALERT, DANGER;
}

class BlackBoard {
    ArrayList<Resource> resources;
    ArrayList<Agent> collective;
    PVector predLastSeen;
    Status status;
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

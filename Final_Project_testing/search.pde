int NODECOUNT = 10;

// Use A* Search to find best path from start to finish
boolean search(Agent agent) {

  float currentCost = 0;
  IntList currentPath = new IntList();
  currentPath.append(0);

  LinkedList<Float> queueCost = new LinkedList<Float>();
  LinkedList<IntList> queuePath = new LinkedList<IntList>();

  // Adds heuristic to node costs (removed when storing currentCost)
  float[] heuristic = new float[NODECOUNT];
  for (int i=0; i<NODECOUNT; i++) {
    float dx = agent.nodePos[i][0] - agent.nodePos[NODECOUNT-1][0];
    float dy = agent.nodePos[i][1] - agent.nodePos[NODECOUNT-1][1];
    heuristic[i] = sqrt(dx*dx + dy*dy)*0.95;
    for (int j=0; j<NODECOUNT; j++) {
      agent.nodeCost[j][i]+=heuristic[i];
    }
  }

  // A* Search
  float startTime, currentTime, timeLimit;  // Prevents A* search from taking too long
  startTime = millis();
  timeLimit = 5;
  while (true) {
    for (int j=0; j<NODECOUNT; j++) {
      currentTime = millis(); if (currentTime-startTime > timeLimit) {print("}:");return false;} 
      if (agent.nodeCost[currentPath.get(currentPath.size()-1)][j] != Float.POSITIVE_INFINITY) {
        if (!currentPath.hasValue(j)) {
          // Add to queue
          boolean addFlag = false;
          for (int k=0; k<queueCost.size(); k++) {
            currentTime = millis(); if (currentTime-startTime > timeLimit) {print("}:");return false;}         
            float costOfTakingPathJ = agent.nodeCost[currentPath.get(currentPath.size()-1)][j] + currentCost;
            float costOfQueuePathK = queueCost.get(k);
            if ( costOfTakingPathJ < costOfQueuePathK ) {
              queueCost.add(k, new Float(agent.nodeCost[currentPath.get(currentPath.size()-1)][j] + currentCost) );
              IntList tempIntList = currentPath.copy();
              tempIntList.append(j);
              queuePath.add(k, tempIntList);
              addFlag = true;
              break;
            }
          }
          if (addFlag == false) {
            queueCost.add(new Float(agent.nodeCost[currentPath.get(currentPath.size()-1)][j] + currentCost));
            IntList tempIntList = currentPath.copy();
            tempIntList.append(j);
            queuePath.add(tempIntList);
          }
        }
      }
    }
    if (queueCost.size()!=0) {
      if (queuePath.getFirst().get(queuePath.getFirst().size()-1) == NODECOUNT-1) {
        agent.answer = queuePath.get(0).copy();
        print("Answer: ", agent.answer, "\n");
        return true;
      }
    }
    if (queueCost.size()==0) {
      print("No Answer\n");
      return false;
    }
    currentCost = queueCost.get(0)-heuristic[queuePath.get(0).get(queuePath.get(0).size()-1)];
    currentPath = queuePath.get(0);
    queueCost.remove();
    queuePath.remove();
  }
}

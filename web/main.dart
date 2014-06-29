library maze;

import 'dart:html';
import 'dart:async';
import 'dart:math' as Math;

part 'maze.dart';

Maze maze;
double lastFrameTime = 0.0;

main()
{
  init();
}

void init() {
  maze = new Maze();
  
  scheduleMicrotask(maze.start);
  window.animationFrame.then(update);
}

void update(double frameTime) {
  double dt = (frameTime - lastFrameTime).toDouble() * 0.001;
  
  maze.update(dt);
  
  lastFrameTime = frameTime;
  window.animationFrame.then(update);
}

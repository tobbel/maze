part of maze;

// This should be called prim's
class Maze {
  static const double UPDATE_TIME = 0.25;
  double updateTimer = UPDATE_TIME;
  
  static const int WIDTH = 96;
  static const int HEIGHT = 96;

  static const int N = 1 << 0;
  static const int S = 1 << 1;
  static const int W = 1 << 2;
  static const int E = 1 << 3;
  
  static const int CELL_SIZE = 4;
  static const int CELL_SPACING = 4;
  
  int cellWidth;
  int cellHeight;
  List<int> edges;      

  CanvasElement canvas;
  CanvasRenderingContext2D context;
  MinHeap maze;
  Math.Random rand = new Math.Random();
  
  Maze() {
    canvas = document.body.append(new CanvasElement(width: WIDTH, height: HEIGHT));
    context = canvas.context2D;
  }
  
  void fillCell(int index) {
    final int i = index % cellWidth;
    final int j = index ~/ cellWidth;
    context.fillRect(
        i * CELL_SIZE + (i + 1) * CELL_SPACING, 
        j * CELL_SIZE + (j + 1) * CELL_SPACING, 
        CELL_SIZE, CELL_SIZE);
  }
  
  void fillEast(int index) {
    final int i = index % cellWidth;
    final int j = index ~/ cellWidth;
    context.fillRect(
        (i + 1) * (CELL_SIZE + CELL_SPACING), 
        j * CELL_SIZE + (j + 1) * CELL_SPACING, 
        CELL_SPACING, CELL_SIZE);
  }
  
  void fillSouth(int index) {
    final int i = index % cellWidth;
    final int j = index ~/ cellWidth;
    context.fillRect(
        i * CELL_SIZE + (i + 1) * CELL_SPACING, 
        (j + 1) * (CELL_SIZE + CELL_SPACING), 
        CELL_SIZE, CELL_SPACING);
  }
  
  void start() {
    cellWidth = (WIDTH - CELL_SPACING) ~/ (CELL_SIZE + CELL_SPACING);
    cellHeight = (HEIGHT - CELL_SPACING) ~/ (CELL_SIZE + CELL_SPACING);
    final int tx = (WIDTH - cellWidth * CELL_SIZE - (cellHeight + 1) * CELL_SPACING) ~/ 2;
    final int ty = (HEIGHT - cellHeight * CELL_SIZE - (cellHeight + 1) * CELL_SPACING) ~/ 2;
    context.translate(tx, ty);
    context.fillStyle = 'white';
    //edges = new List<int>(cellWidth * cellHeight);
    edges = new List<int>.generate(cellWidth * cellHeight, (int index) => -1);
    maze = new MinHeap(compareNodes);
    int start = (cellHeight - 1) * cellWidth;
    edges[start] = 0;
    fillCell(start);
    
    maze.push(new Node(start, N, rand.nextDouble()));
    maze.push(new Node(start, E, rand.nextDouble()));
  }
  bool done = false;
  void update(double dt) {
    if (updateTimer > 0.0 && !done) {
      updateTimer -= dt;
      
      if (updateTimer <= 0.0) {
        updateTimer = UPDATE_TIME;
        done = exploreFrontier();
      }
    }
  }
  
  bool exploreFrontier() {
    Node edge = maze.pop();
    if (edge == null) {
      return true;
    }

    print('Current Edges:');
    for (int y = 0; y < 11; y++) {
      String out = '[';
      for (int x = 0; x < 11; x++) {
        final int index = y * 11 + x;
        out += '${edges[index]},\t';
      }
      out += ']';
      print(out);
    }
    
    print('Current Maze:');
    print(maze.print());
    
    int i0 = edge.index;
    int d0 = edge.direction;
    int i1 = i0 + (d0 == N ? -cellWidth : d0 == S ? cellWidth : d0 == W ? -1 : 1);
    int x0 = i0 % cellWidth;
    int y0 = i0 ~/ cellWidth;
    int x1, y1, d1;
    
    //bool open = edges[i1] == null;
    bool open = edges[i1] == -1;
    
    context.fillStyle = open ? 'white' : 'black';
    if (d0 == N) {
      fillSouth(i1);
      x1 = x0;
      y1 = y0 - 1;
      d1 = S;
    } else if (d0 == S) {
      fillSouth(i0);
      x1 = x0;
      y1 = y0 + 1;
      d1 = N;
    } else if (d0 == W) {
      fillEast(i1);
      x1 = x0 - 1;
      y1 = y0;
      d1 = E;
    } else {
      fillEast(i0);
      x1 = x0 + 1;
      y1 = y0;
      d1 = W;
    }
    
    if (open) {
      fillCell(i1);
      if (edges[i0] != -1) {
        edges[i0] |= d0;        
      } else {
        edges[i0] = d0;
      }
      if (edges[i1] != -1) {
        edges[i1] |= d1;        
      } else {
        edges[i1] = d1;
      }
      
      context.fillStyle = 'magenta';
      
      if (y1 > 0 && edges[i1 - cellWidth] == -1) {
        fillSouth(i1 - cellWidth);
        maze.push(new Node(i1, N, rand.nextDouble()));
      }
      if (y1 < cellHeight - 1 && edges[i1 + cellWidth] == -1) {
        fillSouth(i1);
        maze.push(new Node(i1, S, rand.nextDouble()));
      }
      if (x1 > 0 && edges[i1 - 1] == -1) {
        fillEast(i1 - 1);
        maze.push(new Node(i1, W, rand.nextDouble()));
      }
      if (x1 < cellWidth - 1 && edges[i1 + 1] == -1) {
        fillEast(i1);
        maze.push(new Node(i1, E, rand.nextDouble()));
      }
    }
    
    return false;
  }
  
  double compareNodes(Node a, Node b) {
    return a.weight - b.weight;
  }
}

class Node {
  int index;
  int direction;
  double weight;
  Node(this.index, this.direction, this.weight);
}

class MinHeap {
  MinHeap(this.compare);
  int size = 0;
  var compare;
  List<Node> array = new List<Node>();
  //Map<int, Node> array = new Map<int, Node>();
  bool empty() {
    return size == 0;
  }
   
  int push(Node value) {

    bool contains = false;
    array.forEach((f) {
      if (f.index == value.index) contains = true;
    });
    
    if (contains) {
      array[size] = value;
    }
    else array.add(value);
    
    // Old
    //array[size] = value;
    //up(array[size], size);
    size++;
    return size;
  }
  
  String print() {
    String out = '';
    out += ('Size: ' + size.toString() + '\n');
    out += ('Length: ' + array.length.toString() + '\n');
    for (int i = 0; i < array.length; i++) {
      out += ('[Index: ' + array[i].index.toString() + ', ' + 
              'Direction: ' + array[i].direction.toString() + ', ' + 
              'Weight: ' + array[i].weight.toString() + ']\n');
    }
    return out;
  }
  
  Node pop() {
    if (size <= 0) return null;
    Node removed = array[0];
    Node value;
    size--;
    if (size > 0) {
      value = array[size];
      array[0] = value;
      down(array[0], 0);
    }
    return removed;
  }

  void up(Node value, int i) {
    while (i > 0) {
      final int j = ((i + 1) >> 1) - 1;
      Node parent = array[j];
      
      if (compare(value, parent) >= 0) break;

      array[i] = parent;
      array[j] = value;
      i = j;
    }
  }
  
  void down(Node value, int i) {
    while(true) {
      final int r = (i + 1) << 1;
      final int l = r - 1;
      int j = i;
      Node child = array[j];
      
      if (l < size && compare(array[l], child) < 0.0) {
        child = array[l];
        j = l;
      }
      if (r < size && compare(array[r], child) < 0.0) {
        child = array[r];
        j = r;
      }
      if (j == i) break;
      array[i] = child;
      array[j] = value;
      i = j;
    }
  }
}

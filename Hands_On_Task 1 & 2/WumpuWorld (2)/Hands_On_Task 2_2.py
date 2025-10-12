# --- Wumpus World: Búsqueda en Anchura (BFS) ---

from collections import deque

wumpus_world = [
    ['_', '_', 'W', '_'],
    ['P', '_', 'P', '_'],
    ['_', '_', '_', '_'],
    ['S', '_', '_', 'G']
]

start = (3, 0)
goal = (3, 3)
moves = [(-1,0), (1,0), (0,-1), (0,1)]

def is_valid(x, y):
    if 0 <= x < 4 and 0 <= y < 4:
        if wumpus_world[x][y] not in ['W', 'P']:
            return True
    return False

def bfs(start, goal):
    queue = deque([(start, [start])])
    visited = set()

    while queue:
        (x, y), path = queue.popleft()
        if (x, y) == goal:
            return path
        if (x, y) not in visited:
            visited.add((x, y))
            for dx, dy in moves:
                nx, ny = x + dx, y + dy
                if is_valid(nx, ny) and (nx, ny) not in visited:
                    queue.append(((nx, ny), path + [(nx, ny)]))
    return None

path_bfs = bfs(start, goal)
print("Ruta encontrada (BFS):", path_bfs)
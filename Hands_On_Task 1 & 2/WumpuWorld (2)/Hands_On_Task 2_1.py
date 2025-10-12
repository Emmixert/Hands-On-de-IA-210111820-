# --- Wumpus World: Búsqueda en Profundidad (DFS) ---

from collections import deque

# Representación del mundo (4x4)
# S = inicio, G = oro, W = wumpus, P = pozo, _ = libre
wumpus_world = [
    ['_', '_', 'W', '_'],
    ['P', '_', 'P', '_'],
    ['_', '_', '_', '_'],
    ['S', '_', '_', 'G']
]

start = (3, 0)  # posición de inicio (fila, columna)
goal = (3, 3)   # posición del oro

# Movimientos posibles (arriba, abajo, izquierda, derecha)
moves = [(-1,0), (1,0), (0,-1), (0,1)]

def is_valid(x, y):
    """Verifica si la posición es válida y segura."""
    if 0 <= x < 4 and 0 <= y < 4:
        if wumpus_world[x][y] not in ['W', 'P']:
            return True
    return False

def dfs(start, goal):
    stack = [(start, [start])]
    visited = set()

    while stack:
        (x, y), path = stack.pop()
        if (x, y) == goal:
            return path
        if (x, y) not in visited:
            visited.add((x, y))
            for dx, dy in moves:
                nx, ny = x + dx, y + dy
                if is_valid(nx, ny) and (nx, ny) not in visited:
                    stack.append(((nx, ny), path + [(nx, ny)]))
    return None

path_dfs = dfs(start, goal)
print("Ruta encontrada (DFS):", path_dfs)
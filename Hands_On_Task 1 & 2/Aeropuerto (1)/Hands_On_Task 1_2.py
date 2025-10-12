# --- Búsqueda en Anchura (BFS) en red de aeropuertos ---

from collections import deque

graph = {
    'NY': ['TOR', 'CHI', 'DEN'],
    'TOR': ['CALG', 'LA'],
    'CALG': ['TOR'],
    'CHI': ['DEN'],
    'DEN': ['LA', 'HOU'],
    'HOU': ['URB', 'LA'],
    'LA': ['URB'],
    'URB': []
}

def bfs(graph, start, goal):
    queue = deque([(start, [start])])
    visited = set()

    while queue:
        (node, path) = queue.popleft()
        if node == goal:
            return path
        visited.add(node)
        for neighbor in graph[node]:
            if neighbor not in visited:
                queue.append((neighbor, path + [neighbor]))
    return None

ruta_bfs = bfs(graph, 'NY', 'LA')
print("Ruta encontrada (BFS):", ruta_bfs)
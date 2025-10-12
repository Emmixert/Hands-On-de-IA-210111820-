# --- Búsqueda en Profundidad (DFS) en red de aeropuertos ---

graph = {
    'NY': ['TOR', 'CHI', 'DEN'],
    'TOR': ['CALG', 'LA'],
    'CALG': [],
    'CHI': ['DEN'],
    'DEN': ['LA', 'HOU'],
    'HOU': ['URB', 'LA'],
    'LA': [],
    'URB': []
}

def dfs(graph, start, goal, path=None, visited=None):
    if path is None:
        path = [start]
    if visited is None:
        visited = set()

    visited.add(start)
    if start == goal:
        return path

    for neighbor in graph[start]:
        if neighbor not in visited:
            result = dfs(graph, neighbor, goal, path + [neighbor], visited)
            if result:
                return result
    return None

ruta_dfs = dfs(graph, 'NY', 'LA')
print("Ruta encontrada (DFS):", ruta_dfs)
